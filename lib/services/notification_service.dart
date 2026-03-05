import 'dart:math';
import 'package:conectasoc/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:conectasoc/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:conectasoc/core/utils/quill_helpers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ─────────────────────────────────────────────────────────────
// Handler de mensajes en background (fuera de la clase,
// requerido por firebase_messaging)
// ─────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // En web el background lo maneja el service worker (firebase-messaging-sw.js)
  // Este handler aplica solo a móvil/desktop nativo
  if (kIsWeb) return;
  debugPrint('FCM background message: ${message.messageId}');
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  if (kIsWeb) return;
  Workmanager().executeTask((task, inputData) async {
    // Inicializar dependencias mínimas necesarias
    await initMinimal();

    final authRepository = sl<AuthRepository>();
    final articleRepository = sl<ArticleRepository>();

    // Obtener usuario actual
    final userResult = await authRepository.getSavedUser();
    return userResult.fold(
      (failure) => false,
      (user) async {
        if (user == null || user.notificationFrequency == 'none') return true;

        // Consultar artículos nuevos desde la última notificación
        final articlesResult =
            await articleRepository.getArticlesForNotification(
          lastNotified:
              user.fechaNotificada ?? DateTime.fromMillisecondsSinceEpoch(0),
          associationIds: user.associationIds,
        );

        return articlesResult.fold(
          (failure) => false,
          (articles) async {
            if (articles.isNotEmpty) {
              final notificationService = NotificationService();
              for (final article in articles) {
                // Mostrar una notificación por cada artículo
                await notificationService.showLocalNotification(
                  id: article.id.hashCode,
                  title: quillJsonToPlainText(article.title),
                  body: 'Nueva noticia de ${article.associationShortName}',
                  payload: article.id,
                );
              }

              // 1. Encontrar la fechaNotificacion máxima de los artículos enviados
              final maxFechaNotificacion = articles
                  .map((a) =>
                      a.fechaNotificacion ??
                      DateTime.fromMillisecondsSinceEpoch(0))
                  .reduce((a, b) => a.isAfter(b) ? a : b);

              // 2. Actualizar fechaNotificada del usuario con la real de los artículos
              await authRepository.updateUserFechaNotificada(
                  user.uid, maxFechaNotificacion);
            }
            return true;
          },
        );
      },
    );
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream para que la UI escuche los clics en las notificaciones
  final BehaviorSubject<String?> _onNotificationClick =
      BehaviorSubject<String?>();
  Stream<String?> get onNotificationClick => _onNotificationClick.stream;

  // ───────────────────────────────────────────────────────────
  // init — rama WEB vs móvil
  // ───────────────────────────────────────────────────────────
  Future<void> init() async {
    if (kIsWeb) {
      await _initWeb();
      return;
    }
    await _initMobile();
  }

  // ───────────────────────────────────────────────────────────
  // WEB: inicialización FCM
  // ───────────────────────────────────────────────────────────
  Future<void> _initWeb() async {
    // 1. Registrar el handler de background
    //    (en web no hace nada, pero es buena práctica declararlo)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Solicitar permiso al usuario (obligatorio en web)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM Web: permiso denegado por el usuario');
      return;
    }

    // 3. Obtener token FCM web (requiere VAPID key)
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: DefaultFirebaseOptions.vapidKey,
    );
    debugPrint('FCM Web Token: $token');
    // TODO: guarda el token donde lo necesites (Firestore, shared preferences, etc.)

    // 4. Escuchar mensajes en FOREGROUND (app abierta)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Web foreground: ${message.notification?.title}');

      // Emitir el payload para que la UI pueda reaccionar
      // (p.ej. navegar al artículo correspondiente)
      final payload = message.data['articleId'] as String?;
      if (payload != null) {
        _onNotificationClick.add(payload);
      }

      // Opcionalmente puedes mostrar un banner/snackbar desde aquí
      // usando un GlobalKey<ScaffoldMessengerState> o similar
    });

    // 5. App abierta desde notificación (estaba en background, usuario toca)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'NotificationService: _initWeb -> FCM Web onMessageOpenedApp: ${message.notification?.title}');
      debugPrint(
          'NotificationService: _initWeb -> FCM Web onMessageOpenedApp: ${message.data}');
      final payload = message.data['articleId'] as String?;
      if (payload != null) {
        _onNotificationClick.add(payload);
      }
    });

    // 6. App lanzada desde notificación (estaba completamente cerrada)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final payload = initialMessage.data['articleId'] as String?;
      if (payload != null) {
        // Pequeño delay para que la UI esté montada
        Future.delayed(const Duration(seconds: 1), () {
          _onNotificationClick.add(payload);
        });
      }
    }
  }

  // ───────────────────────────────────────────────────────────
  // MÓVIL: inicialización flutter_local_notifications + workmanager
  // ───────────────────────────────────────────────────────────
  Future<void> _initMobile() async {
    // Registrar handler FCM background también en móvil
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _onNotificationClick.add(response.payload);
        }
      },
    );

    await Workmanager().initialize(
      callbackDispatcher,
    );

    // Manejar el caso en que la app se abre desde una notificación (app cerrada)
    final NotificationAppLaunchDetails? launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      if (launchDetails.notificationResponse?.payload != null) {
        // Retrasar un poco para que la UI esté lista
        Future.delayed(const Duration(seconds: 1), () {
          _onNotificationClick.add(launchDetails.notificationResponse!.payload);
        });
      }
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showLocalNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'news_channel',
      'Noticias',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Método manual para verificar notificaciones (útil para pruebas y debug)
  Future<bool> checkNow() async {
    if (kIsWeb) return false;

    // Inicializar dependencias mínimas necesarias
    await initMinimal();

    final authRepository = sl<AuthRepository>();
    final articleRepository = sl<ArticleRepository>();

    // Obtener usuario actual
    final userResult = await authRepository.getSavedUser();
    return userResult.fold(
      (failure) => false,
      (user) async {
        if (user == null || user.notificationFrequency == 'none') return true;

        // Consultar artículos nuevos desde la última notificación
        final articlesResult =
            await articleRepository.getArticlesForNotification(
          lastNotified:
              user.fechaNotificada ?? DateTime.fromMillisecondsSinceEpoch(0),
          associationIds: user.associationIds,
        );

        return articlesResult.fold(
          (failure) => false,
          (articles) async {
            if (articles.isNotEmpty) {
              final notificationService = NotificationService();
              for (final article in articles) {
                // Mostrar una notificación por cada artículo
                await notificationService.showLocalNotification(
                  id: article.id.hashCode,
                  title: quillJsonToPlainText(article.title),
                  body: 'Nueva noticia de ${article.associationShortName}',
                  payload: article.id,
                );
              }

              // 1. Encontrar la fechaNotificacion máxima de los artículos enviados
              final maxFechaNotificacion = articles
                  .map((a) =>
                      a.fechaNotificacion ??
                      DateTime.fromMillisecondsSinceEpoch(0))
                  .reduce((a, b) => a.isAfter(b) ? a : b);

              // 2. Actualizar fechaNotificada del usuario con la real de los artículos
              await authRepository.updateUserFechaNotificada(
                  user.uid, maxFechaNotificacion);
            }
            return true;
          },
        );
      },
    );
  }

  /// Programa las tareas según la frecuencia del usuario
  Future<void> scheduleNotifications(UserEntity user) async {
    if (kIsWeb) return;
    await Workmanager().cancelAll();

    if (user.notificationFrequency == 'none') return;

    final schedules = _getSchedulesForFrequency(user.notificationFrequency);

    for (int i = 0; i < schedules.length; i++) {
      final scheduleTime = schedules[i];
      final delay = _calculateDelayWithRandomOffset(scheduleTime);

      await Workmanager().registerOneOffTask(
        'news_task_${user.uid}_$i',
        'check_news_task',
        initialDelay: delay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: {'userId': user.uid},
      );
    }
  }

  List<TimeOfDay> _getSchedulesForFrequency(String frequency) {
    switch (frequency) {
      case 'once_day':
        return [const TimeOfDay(hour: 12, minute: 0)];
      case 'twice_day':
        return [
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
      case 'thrice_day':
        return [
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
      default:
        return [];
    }
  }

  Duration _calculateDelayWithRandomOffset(TimeOfDay scheduledTime) {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Offset aleatorio de +- 30 minutos
    final random = Random();
    final offsetMinutes = random.nextInt(61) - 30; // -30 a +30
    scheduledDate = scheduledDate.add(Duration(minutes: offsetMinutes));

    // Asegurarse de que el delay no sea negativo
    var delay = scheduledDate.difference(DateTime.now());
    if (delay.isNegative) {
      delay = const Duration(
          minutes:
              1); // Ejecutar casi de inmediato si el offset lo saca de rango
    }

    return delay;
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: id);
  }
}
