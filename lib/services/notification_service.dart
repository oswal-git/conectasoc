import 'package:conectasoc/core/utils/utils.dart';
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
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
  debugPrint(
      'ℹ️ NotificationService: _firebaseMessagingBackgroundHandler -> FCM background message: ${message.messageId}');
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  if (kIsWeb) return;
  Workmanager().executeTask((task, inputData) async {
    debugPrint(
        '${fechaD('🔔')} callbackDispatcher: WorkManager task started: $task');

// Obtener parámetros del inputData
    final userId = inputData?['userId'] as String?;
    final taskIndex = inputData?['taskIndex'] as int?;
    final scheduledHour = inputData?['scheduledHour'] as int?;
    final scheduledMinute = inputData?['scheduledMinute'] as int?;

    debugPrint('${fechaD('🔔')} callbackDispatcher: userId: $userId');
    debugPrint('${fechaD('🔔')} callbackDispatcher: taskIndex: $taskIndex');
    debugPrint(
        '${fechaD('🔔')} callbackDispatcher: scheduledHour: $scheduledHour');
    debugPrint(
        '${fechaD('🔔')} callbackDispatcher: scheduledMinute: $scheduledMinute');

    if (userId == null ||
        taskIndex == null ||
        scheduledHour == null ||
        scheduledMinute == null) {
      debugPrint(
          '${fechaD('🔔')} callbackDispatcher: WorkManager: Missing inputData params');
      return false;
    }

    // Inicializar dependencias mínimas necesarias
    await initMinimal();

// ── Lógica de negocio ─────────────────────────────────────
    bool taskSuccess = false;

    try {
      final userRepository = sl<UserRepository>();
      final authRepository = sl<AuthRepository>();
      final articleRepository = sl<ArticleRepository>();

      // Obtener usuario por ID en lugar del guardado
      final userResult = await userRepository.getUserById(userId);

      taskSuccess = await userResult.fold(
        (failure) async {
          debugPrint(
              '${fechaD('❌')} callbackDispatcher: WorkManager: Failed to get user - ${failure.message}');
          return false;
        },
        (user) async {
          if (((user.notificationTime1 == null ||
                  user.notificationTime1!.isEmpty) &&
              (user.notificationTime2 == null ||
                  user.notificationTime2!.isEmpty) &&
              (user.notificationTime3 == null ||
                  user.notificationTime3!.isEmpty))) {
            debugPrint(
                '${fechaD('❌')} callbackDispatcher: WorkManager: User has no notification times configured');
            return true;
          }

          // Consultar artículos nuevos desde la última notificación
          final articlesResult =
              await articleRepository.getArticlesForNotification(
            lastNotified:
                user.fechaNotificada ?? DateTime.fromMillisecondsSinceEpoch(0),
            associationIds: user.associationIds,
          );

          return articlesResult.fold(
            (failure) {
              debugPrint(
                  '${fechaD('❌')} callbackDispatcher: WorkManager: Failed to get articles - ${failure.message}');
              return false;
            },
            (articles) async {
              debugPrint(
                  '${fechaD('🔔')} callbackDispatcher: WorkManager: Found ${articles.length} new articles');
              if (articles.isNotEmpty) {
                final notificationService = NotificationService();

                // Ordenar por fechaNotificacion para procesar en orden cronológico
                final sortedArticles = [...articles]..sort((a, b) {
                    final dateA = a.fechaNotificacion ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                    final dateB = b.fechaNotificacion ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                    return dateA.compareTo(dateB);
                  });

                for (final article in sortedArticles) {
                  // Mostrar una notificación por cada artículo
                  await notificationService.showLocalNotification(
                    id: article.id.hashCode,
                    title: quillJsonToPlainText(article.title),
                    body: 'Nueva noticia de ${article.associationShortName}',
                    payload: article.id,
                  );
                  debugPrint(
                      '${fechaD('🔔')} callbackDispatcher: WorkManager: Notification sent for article ${article.id}');
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
                debugPrint(
                    '${fechaD('🔔')} callbackDispatcher: WorkManager: Updated fechaNotificada for user ${user.uid} to $maxFechaNotificacion');
              } else {
                debugPrint(
                    '📭 callbackDispatcher: WorkManager: No new articles found');
              }
              return true;
            },
          );
        },
      );
    } catch (e) {
      debugPrint('❌ WorkManager: Unexpected error - $e');
      taskSuccess = false;
    }

    // ✅ Reprogramar para mañana a la misma hora, independientemente del resultado
    // Solo si la tarea no falló por falta de parámetros
    try {
      final nextSchedule =
          TimeOfDay(hour: scheduledHour, minute: scheduledMinute);
      final nextDelay = _calculateDelayWithDeterministicOffset(
        nextSchedule,
        userId,
        taskIndex,
        // Forzar mañana: aunque la hora aún no haya pasado hoy,
        // ya estamos dentro de la ejecución de hoy
        forceNextDay: true,
      );

      await Workmanager().registerOneOffTask(
        'news_task_${userId}_$taskIndex',
        'check_news_task',
        initialDelay: nextDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: {
          'userId': userId,
          'taskIndex': taskIndex,
          'scheduledHour': scheduledHour,
          'scheduledMinute': scheduledMinute,
        },
      );

      debugPrint(
          '🔁 WorkManager: Rescheduled task $taskIndex for tomorrow at $scheduledHour:$scheduledMinute (delay: ${nextDelay.inMinutes} min)');
    } catch (e) {
      debugPrint('❌ WorkManager: Failed to reschedule task - $e');
    }
    return taskSuccess;
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
      debugPrint(
          'ℹ️ NotificationService: _initWeb -> FCM Web: permiso denegado por el usuario');
      return;
    }

    // 3. Obtener token FCM web (requiere VAPID key)
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: DefaultFirebaseOptions.vapidKey,
    );
    debugPrint('ℹ️ NotificationService: _initWeb -> FCM Web Token: $token');
    // TODO: guarda el token donde lo necesites (Firestore, shared preferences, etc.)

    // 4. Escuchar mensajes en FOREGROUND (app abierta)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          'ℹ️ NotificationService: _initWeb -> FCM Web foreground: ${message.notification?.title}');

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
          'ℹ️ NotificationService: _initWeb -> FCM Web onMessageOpenedApp: ${message.notification?.title}');
      debugPrint(
          'ℹ️ NotificationService: _initWeb -> FCM Web onMessageOpenedApp: ${message.data}');
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
        _onNotificationClick.add(payload);
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

    try {
      await Workmanager().initialize(callbackDispatcher);
    } catch (e) {
      debugPrint(
          '❌ NotificationService: _initMobile -> Workmanager init failed: $e');
    }

    // Manejar el caso en que la app se abre desde una notificación (app cerrada)
    final NotificationAppLaunchDetails? launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      if (launchDetails.notificationResponse?.payload != null) {
        _onNotificationClick.add(launchDetails.notificationResponse!.payload);
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
        if (user == null ||
            ((user.notificationTime1 == null ||
                    user.notificationTime1!.isEmpty) &&
                (user.notificationTime2 == null ||
                    user.notificationTime2!.isEmpty) &&
                (user.notificationTime3 == null ||
                    user.notificationTime3!.isEmpty))) {
          return true;
        }

        // 🔧 FIX: Usar fechaNotificada o una fecha por defecto muy antigua
        final lastNotified =
            user.fechaNotificada ?? DateTime.fromMillisecondsSinceEpoch(0);

        debugPrint('🔔 checkNow: lastNotified = $lastNotified');
        debugPrint('🔔 checkNow: user associationIds = ${user.associationIds}');

        // Consultar artículos nuevos desde la última notificación
        final articlesResult =
            await articleRepository.getArticlesForNotification(
          lastNotified: lastNotified,
          associationIds: user.associationIds,
        );

        return articlesResult.fold(
          (failure) {
            debugPrint(
                '❌ checkNow: error getting articles - ${failure.message}');
            return false;
          },
          (articles) async {
            debugPrint('📰 checkNow: found ${articles.length} new articles');

            if (articles.isNotEmpty) {
              final notificationService = NotificationService();

              // 🔧 FIX: Ordenar artículos por fechaNotificacion para asegurar que la más reciente sea la última
              final sortedArticles = [...articles]..sort((a, b) {
                  final dateA = a.fechaNotificacion ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  final dateB = b.fechaNotificacion ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  return dateA.compareTo(dateB);
                });

              for (final article in sortedArticles) {
                // Mostrar una notificación por cada artículo
                await notificationService.showLocalNotification(
                  id: article.id.hashCode,
                  title: quillJsonToPlainText(article.title),
                  body: 'Nueva noticia de ${article.associationShortName}',
                  payload: article.id,
                );
                debugPrint(
                    '✅ Notificación enviada para artículo: ${article.id}');
              }

              // 1. Encontrar la fechaNotificacion máxima de los artículos enviados
              final maxFechaNotificacion = sortedArticles
                  .map((a) =>
                      a.fechaNotificacion ??
                      DateTime.fromMillisecondsSinceEpoch(0))
                  .reduce((a, b) => a.isAfter(b) ? a : b);

              debugPrint(
                  '📅 Actualizando fechaNotificada de $lastNotified a $maxFechaNotificacion');

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
    debugPrint(
        '${fechaD('✅')} NotificationService -> scheduleNotifications: Workmanager().cancelAll()');

    final schedules = <TimeOfDay>[];

    void addScheduleIfValid(String? timeStr) {
      if (timeStr != null && timeStr.isNotEmpty && timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final h = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          if (h != null && m != null) {
            schedules.add(TimeOfDay(hour: h, minute: m));
          }
        }
      }
    }

    addScheduleIfValid(user.notificationTime1);
    addScheduleIfValid(user.notificationTime2);
    addScheduleIfValid(user.notificationTime3);

    if (schedules.isEmpty) return;

    for (int i = 0; i < schedules.length; i++) {
      final scheduleTime = schedules[i];
      final delay =
          _calculateDelayWithDeterministicOffset(scheduleTime, user.uid, i);

      await Workmanager().registerOneOffTask(
        'news_task_${user.uid}_$i',
        'check_news_task',
        initialDelay: delay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: {
          'userId': user.uid,
          'taskIndex': i,
          'scheduledHour': scheduleTime.hour,
          'scheduledMinute': scheduleTime.minute,
        },
      );

      debugPrint(
          '${fechaD('✅')} NotificationService -> scheduleNotifications: Scheduled notification for ${user.uid} at ${formatTimeOfDay(scheduleTime)} (delay: ${delay.inMinutes} min)');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: id);
  }
}

Duration _calculateDelayWithDeterministicOffset(
  TimeOfDay scheduledTime,
  String uid,
  int taskIndex, {
  bool forceNextDay = false,
}) {
  final now = DateTime.now();
  var scheduledDate = DateTime(
    now.year,
    now.month,
    now.day,
    scheduledTime.hour,
    scheduledTime.minute,
  );

  // Offset determinista: hash del uid → siempre el mismo para cada usuario
  // Rango: -30 a +30 minutos
  final hashValue =
      uid.codeUnits.fold(0, (prev, c) => prev + c) + (taskIndex * 7);
  final offsetMinutes = (hashValue % 61) - 30; // -30 a +30

  debugPrint(
      '${fechaD('✅')} NotificationService -> _calculateDelayWithDeterministicOffset: index $taskIndex, ${scheduledTime.hour}:${scheduledTime.minute} delay: $offsetMinutes min)');

  scheduledDate = scheduledDate.add(Duration(minutes: offsetMinutes));

  // Si tras el offset la hora ya pasó (o queda menos de 1 min), programar mañana
  if (forceNextDay ||
      scheduledDate.isBefore(now) ||
      scheduledDate.difference(now).inMinutes < 1) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate.difference(DateTime.now());
}
