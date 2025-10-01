import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/services/local_storage_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // ============================================
  // SERVICIOS EXTERNOS (Firebase)
  // ============================================

  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ============================================
  // SERVICIOS LOCALES
  // ============================================

  // Local Storage Service (Singleton asíncrono)
  final localStorage = await LocalStorageService.getInstance();
  getIt.registerSingleton<LocalStorageService>(localStorage);

  // ============================================
  // REPOSITORIOS
  // ============================================

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      localStorage: getIt<LocalStorageService>(),
    ),
  );

  // ============================================
  // BLoCs
  // ============================================

  // AuthBloc como Factory (nueva instancia cada vez que se necesite)
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );
}
