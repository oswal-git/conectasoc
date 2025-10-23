// lib/injection_container.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:conectasoc/core/services/translation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:conectasoc/core/services/local_storage_service.dart';
import 'package:conectasoc/services/cloudinary_service.dart';

// Associations - Data
import 'package:conectasoc/features/associations/data/datasources/association_remote_datasource.dart';
import 'package:conectasoc/features/associations/data/repositories/association_repository_impl.dart';

// Associations - Domain
import 'package:conectasoc/features/associations/domain/repositories/association_repository.dart';
import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';

// Associations - Presentation
import 'package:conectasoc/features/associations/presentation/bloc/association_bloc.dart';
import 'package:conectasoc/features/associations/presentation/bloc/edit/association_edit_bloc.dart';

// Home - Presentation
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';

// Users - Data
import 'package:conectasoc/features/users/data/datasources/user_remote_datasource.dart';
import 'package:conectasoc/features/users/data/repositories/users_repository_impl.dart';

// Users - Domain
import 'package:conectasoc/features/users/domain/repositories/repositories.dart';
import 'package:conectasoc/features/users/domain/usecases/usecases.dart';

// Users - Presentation
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';

// Auth - Data
import 'package:conectasoc/features/auth/data/datasources/datasources.dart';
import 'package:conectasoc/features/auth/data/repositories/auth_repository_impl.dart';

// Auth - Domain
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';
import 'package:conectasoc/features/auth/domain/usecases/usecases.dart';

// Auth - Presentation
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';

// Articles - Data
import 'package:conectasoc/features/articles/data/repositories/article_repository_impl.dart';

// Articles - Domain
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';

// Articles - Presentation
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================
  // FEATURES - AUTH
  // ============================================

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      repository: sl(),
      registerUseCase: sl(),
      saveLocalUserUseCase: sl(),
    ),
  );

  // Register Bloc
  sl.registerFactory(
    () => RegisterBloc(
      getAllAssociationsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => LocalUserSetupBloc(
      getAllAssociationsUseCase: sl(),
    ),
  );

  // Use Cases
  // Login y Logout son ahora llamados directamente desde el repositorio en el BLoC.
  // sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  // sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(
        repository: sl(),
        createAssociationUseCase: sl(),
      ));
  sl.registerLazySingleton(() => SaveLocalUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      userRepository: sl(),
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

  // User List
  sl.registerFactory(
    () => UserListBloc(
      getAllUsersUseCase: sl(),
      getUsersByAssociationUseCase: sl(),
    ),
  );

  // User Feature
  sl.registerFactory(
      () => UserBloc(joinAssociationUseCase: sl(), authBloc: sl()));
  sl.registerLazySingleton(() => JoinAssociationUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersByAssociationUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(repository: sl()));
  sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: sl()));
  // Se elimina la dependencia de FirebaseStorage, ya que se usa CloudinaryService.
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(firestore: sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));

  sl.registerFactory(
    () => ProfileBloc(
      userRepository: sl(),
    ),
  );

  // User Edit
  sl.registerFactory(
    () => UserEditBloc(
      getUserByIdUseCase: sl(),
      updateUserUseCase: sl(),
      getAllAssociationsUseCase: sl(),
      deleteUserUseCase: sl(),
      createUserUseCase: sl(),
    ),
  );

  // Associations Feature
  sl.registerFactory(
    () => AssociationBloc(
      getAllAssociationsUseCase: sl(),
      deleteAssociationUseCase: sl(),
      undoDeleteAssociationUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AssociationEditBloc(
      createAssociation: sl(),
      getAssociationById: sl(),
      getUsersByAssociation: sl(),
      updateAssociation: sl(),
      deleteAssociation: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllAssociationsUseCase(sl()));
  sl.registerLazySingleton(() => GetAssociationByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAssociationUseCase(sl()));
  sl.registerLazySingleton(() => CreateAssociationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAssociationUseCase(sl()));
  sl.registerLazySingleton(() => UndoDeleteAssociationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AssociationRepository>(
    () => AssociationRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AssociationRemoteDataSource>(
    () => AssociationRemoteDataSourceImpl(firestore: sl()),
  );

  // ============================================
  // FEATURES - ARTICLES & HOME
  // ============================================

  // Bloc
  sl.registerFactory(
    () => HomeBloc(
        getArticlesUseCase: sl(),
        getCategoriesUseCase: sl(),
        getSubcategoriesUseCase: sl(),
        getAllAssociationsUseCase: sl(),
        translationService: sl(),
        authBloc: sl()),
  );

  sl.registerFactory(() => ArticleBloc(
        getArticlesUseCase: sl(),
        authBloc: sl(),
      ));

  sl.registerFactoryParam<ArticleEditBloc, AuthBloc, void>(
    (authBloc, _) => ArticleEditBloc(
      createArticleUseCase: sl(),
      updateArticleUseCase: sl(),
      deleteArticleUseCase: sl(),
      getArticleByIdUseCase: sl(),
      getCategoriesUseCase: sl(),
      getSubcategoriesUseCase: sl(),
      authBloc: authBloc, // Se pasa desde el contexto
    ),
  );

  sl.registerFactory(() => ArticleDetailBloc(
        authBloc: sl(),
        getArticleByIdUseCase: sl(),
        translationService: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetArticlesUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetSubcategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetArticleByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateArticleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateArticleUseCase(sl()));
  sl.registerLazySingleton(() => DeleteArticleUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(firestore: sl()),
  );

  // ============================================
  // CORE
  // ============================================

  // Services
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(sl()),
  );
  sl.registerLazySingleton(() => CloudinaryService());
  sl.registerLazySingleton(() => TranslationService());

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
