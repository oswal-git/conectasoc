import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:conectasoc/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
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
              // Mostrar notificación local
              await NotificationService().showLocalNotification(
                title: 'Nuevas noticias',
                body: 'Tienes ${articles.length} nuevas noticias en ConectAsoc',
              );

              // Actualizar fechaNotificada del usuario
              await authRepository.updateUserFechaNotificada(
                  user.uid, DateTime.now());
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

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
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
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  /// Programa las tareas según la frecuencia del usuario
  Future<void> scheduleNotifications(UserEntity user) async {
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
}
