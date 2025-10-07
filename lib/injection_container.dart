// lib/injection_container.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/associations/domain/usecases/get_all_associations_usecase.dart';
import 'package:conectasoc/features/associations/presentation/bloc/association_bloc.dart';
import 'package:conectasoc/features/users/data/repositories/users_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Users - Data
import 'package:conectasoc/features/users/data/datasources/user_remote_datasource.dart';

// Users - Presentation
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';

// Users - Domain
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:conectasoc/features/users/domain/usecases/usecases.dart';

// Core
import 'package:conectasoc/core/services/local_storage_service.dart';

// Auth - Data
import 'package:conectasoc/features/auth/data/datasources/datasources.dart';
import 'package:conectasoc/features/auth/data/repositories/auth_repository_impl.dart';

// Auth - Domain
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';
import 'package:conectasoc/features/auth/domain/usecases/usecases.dart';

// Auth - Presentation
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================
  // FEATURES - AUTH
  // ============================================

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      repository: sl(),
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      saveLocalUserUseCase: sl(),
      getAssociationsUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SaveLocalUserUseCase(sl()));
  sl.registerLazySingleton(() => GetAssociationsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      localStorage: sl(),
    ),
  );

  // User Feature
  sl.registerLazySingleton<UserBloc>(
      () => UserBloc(joinAssociationUseCase: sl(), authBloc: sl()));
  sl.registerLazySingleton(() => JoinAssociationUseCase(sl()));
  sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: sl()));
  // Se elimina la dependencia de FirebaseStorage, ya que se usa CloudinaryService.
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(firestore: sl()));

  sl.registerFactory(
    () => ProfileBloc(
      userRepository: sl(),
    ),
  );

  // Associations Feature
  sl.registerFactory(
    () => AssociationBloc(
      getAllAssociationsUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllAssociationsUseCase(sl()));

  // ============================================
  // CORE
  // ============================================

  // Services
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(sl()),
  );

  // ============================================
  // EXTERNAL
  // ============================================

  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
