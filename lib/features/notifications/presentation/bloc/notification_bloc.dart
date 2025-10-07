// // Estados
// abstract class NotificationState extends Equatable {
//   const NotificationState();

//   @override
//   List<Object?> get props => [];
// }

// class NotificationInitial extends NotificationState {}

// class NotificationLoading extends NotificationState {}

// class NotificationLoaded extends NotificationState {
//   final List<NotificationEntity> notifications;
//   final int unreadCount;
//   final bool hasMore;

//   const NotificationLoaded({
//     required this.notifications,
//     required this.unreadCount,
//     this.hasMore = false,
//   });

//   @override
//   List<Object?> get props => [notifications, unreadCount, hasMore];
// }

// class NotificationError extends NotificationState {
//   final String message;

//   const NotificationError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// // Eventos
// abstract class NotificationEvent extends Equatable {
//   const NotificationEvent();

//   @override
//   List<Object?> get props => [];
// }

// class NotificationLoadRequested extends NotificationEvent {}

// class NotificationMarkAsRead extends NotificationEvent {
//   final String notificationId;

//   const NotificationMarkAsRead(this.notificationId);

//   @override
//   List<Object?> get props => [notificationId];
// }

// class NotificationMarkAllAsRead extends NotificationEvent {}

// class NotificationReceived extends NotificationEvent {
//   final RemoteMessage message;

//   const NotificationReceived(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// // BLoC
// class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
//   final NotificationRepository _repository;
//   StreamSubscription? _notificationSubscription;

//   NotificationBloc({required NotificationRepository repository})
//       : _repository = repository,
//         super(NotificationInitial()) {
//     on<NotificationLoadRequested>(_onLoadRequested);
//     on<NotificationMarkAsRead>(_onMarkAsRead);
//     on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
//     on<NotificationReceived>(_onNotificationReceived);

//     // Escuchar notificaciones en tiempo real
//     _setupNotificationListener();
//   }

//   void _setupNotificationListener() {
//     _notificationSubscription = _repository.getNotificationStream().listen(
//       (notifications) {
//         final unreadCount = notifications.where((n) => !n.read).length;
//         emit(NotificationLoaded(
//           notifications: notifications,
//           unreadCount: unreadCount,
//         ));
//       },
//     );
//   }

//   Future<void> _onLoadRequested(
//     NotificationLoadRequested event,
//     Emitter<NotificationState> emit,
//   ) async {
//     emit(NotificationLoading());

//     try {
//       final result = await _repository.getUserNotifications();

//       result.fold(
//         (failure) => emit(NotificationError(failure.message)),
//         (notifications) {
//           final unreadCount = notifications.where((n) => !n.read).length;
//           emit(NotificationLoaded(
//             notifications: notifications,
//             unreadCount: unreadCount,
//           ));
//         },
//       );
//     } catch (e) {
//       emit(NotificationError(e.toString()));
//     }
//   }

//   Future<void> _onMarkAsRead(
//     NotificationMarkAsRead event,
//     Emitter<NotificationState> emit,
//   ) async {
//     try {
//       await _repository.markNotificationAsRead(event.notificationId);

//       // El estado se actualizará automáticamente por el stream
//     } catch (e) {
//       // Manejar error si es necesario
//     }
//   }

//   @override
//   Future<void> close() {
//     _notificationSubscription?.cancel();
//     return super.close();
//   }
// }
