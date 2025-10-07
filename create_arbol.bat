@echo off
setlocal

echo Creando estructura de directorios y archivos en lib...

:: Crear directorio principal lib
:: mkdir lib

:: main.dart en raíz de lib
echo. > lib\main.dart

:: Crear app/
mkdir lib\app
echo. > lib\app\app.dart

:: app/router/
mkdir lib\app\router
echo. > lib\app\router\app_router.dart
echo. > lib\app\router\route_names.dart

:: app/theme/
mkdir lib\app\theme
echo. > lib\app\theme\app_theme.dart
echo. > lib\app\theme\colors.dart
echo. > lib\app\theme\text_styles.dart

:: core/
mkdir lib\core

:: core/constants/
mkdir lib\core\constants
echo. > lib\core\constants\api_constants.dart
echo. > lib\core\constants\app_constants.dart
echo. > lib\core\constants\storage_constants.dart

:: core/errors/
mkdir lib\core\errors
echo. > lib\core\errors\failures.dart
echo. > lib\core\errors\exceptions.dart

:: core/network/
mkdir lib\core\network
echo. > lib\core\network\network_info.dart
echo. > lib\core\network\firebase_service.dart

:: core/platform/
mkdir lib\core\platform
echo. > lib\core\platform\device_info.dart
echo. > lib\core\platform\permissions.dart

:: core/utils/
mkdir lib\core\utils
echo. > lib\core\utils\validators.dart
echo. > lib\core\utils\formatters.dart
echo. > lib\core\utils\helpers.dart
echo. > lib\core\utils\logger.dart

:: features/
mkdir lib\features

:: features/auth/
mkdir lib\features\auth

:: auth/data/
mkdir lib\features\auth\data

:: auth/data/datasources/
mkdir lib\features\auth\data\datasources
echo. > lib\features\auth\data\datasources\auth_local_datasource.dart
echo. > lib\features\auth\data\datasources\auth_remote_datasource.dart

:: auth/data/models/
mkdir lib\features\auth\data\models
echo. > lib\features\auth\data\models\user_model.dart
echo. > lib\features\auth\data\models\auth_request_model.dart

:: auth/data/repositories/
mkdir lib\features\auth\data\repositories
echo. > lib\features\auth\data\repositories\auth_repository_impl.dart

:: auth/domain/
mkdir lib\features\auth\domain

:: auth/domain/entities/
mkdir lib\features\auth\domain\entities
echo. > lib\features\auth\domain\entities\user_entity.dart

:: auth/domain/repositories/
mkdir lib\features\auth\domain\repositories
echo. > lib\features\auth\domain\repositories\auth_repository.dart

:: auth/domain/usecases/
mkdir lib\features\auth\domain\usecases
echo. > lib\features\auth\domain\usecases\login_usecase.dart
echo. > lib\features\auth\domain\usecases\register_usecase.dart
echo. > lib\features\auth\domain\usecases\logout_usecase.dart

:: auth/presentation/
mkdir lib\features\auth\presentation

:: auth/presentation/bloc/
mkdir lib\features\auth\presentation\bloc
echo. > lib\features\auth\presentation\bloc\auth_bloc.dart
echo. > lib\features\auth\presentation\bloc\auth_event.dart
echo. > lib\features\auth\presentation\bloc\auth_state.dart

:: auth/presentation/pages/
mkdir lib\features\auth\presentation\pages
echo. > lib\features\auth\presentation\pages\login_page.dart
echo. > lib\features\auth\presentation\pages\register_page.dart
echo. > lib\features\auth\presentation\pages\splash_page.dart

:: auth/presentation/widgets/
mkdir lib\features\auth\presentation\widgets
echo. > lib\features\auth\presentation\widgets\login_form.dart
echo. > lib\features\auth\presentation\widgets\register_form.dart
echo. > lib\features\auth\presentation\widgets\auth_text_field.dart


:: features/home/
mkdir lib\features\home

:: home/data/
mkdir lib\features\home\data

:: home/data/datasources/
mkdir lib\features\home\data\datasources
echo. > lib\features\home\data\datasources\home_local_datasource.dart
echo. > lib\features\home\data\datasources\home_remote_datasource.dart

:: home/data/models/
mkdir lib\features\home\data\models
echo. > lib\features\home\data\models\home_model.dart
echo. > lib\features\home\data\models\item_home_model.dart
echo. > lib\features\home\data\models\category_model.dart

:: home/data/repositories/
mkdir lib\features\home\data\repositories
echo. > lib\features\home\data\repositories\home_repository_impl.dart

:: home/domain/
mkdir lib\features\home\domain

:: home/domain/entities/
mkdir lib\features\home\domain\entities
echo. > lib\features\home\domain\entities\home_entity.dart
echo. > lib\features\home\domain\entities\item_home_entity.dart

:: home/domain/repositories/
mkdir lib\features\home\domain\repositories
echo. > lib\features\home\domain\repositories\home_repository.dart

:: home/domain/usecases/
mkdir lib\features\home\domain\usecases
echo. > lib\features\home\domain\usecases\get_home_usecase.dart
echo. > lib\features\home\domain\usecases\create_home_usecase.dart
echo. > lib\features\home\domain\usecases\update_home_usecase.dart
echo. > lib\features\home\domain\usecases\delete_home_usecase.dart

:: home/presentation/
mkdir lib\features\home\presentation

:: home/presentation/bloc/
mkdir lib\features\home\presentation\bloc
echo. > lib\features\home\presentation\bloc\home_bloc.dart
echo. > lib\features\home\presentation\bloc\home_detail_bloc.dart
echo. > lib\features\home\presentation\bloc\home_editor_bloc.dart

:: home/presentation/pages/
mkdir lib\features\home\presentation\pages
echo. > lib\features\home\presentation\pages\home_list_page.dart
echo. > lib\features\home\presentation\pages\home_detail_page.dart
echo. > lib\features\home\presentation\pages\home_editor_page.dart

:: home/presentation/widgets/
mkdir lib\features\home\presentation\widgets
echo. > lib\features\home\presentation\widgets\home_card.dart
echo. > lib\features\home\presentation\widgets\home_content.dart
echo. > lib\features\home\presentation\widgets\rich_text_editor.dart
echo. > lib\features\home\presentation\widgets\image_picker_widget.dart


:: features/articles/
mkdir lib\features\articles

:: articles/data/
mkdir lib\features\articles\data

:: articles/data/datasources/
mkdir lib\features\articles\data\datasources
echo. > lib\features\articles\data\datasources\articles_local_datasource.dart
echo. > lib\features\articles\data\datasources\articles_remote_datasource.dart

:: articles/data/models/
mkdir lib\features\articles\data\models
echo. > lib\features\articles\data\models\article_model.dart
echo. > lib\features\articles\data\models\item_article_model.dart
echo. > lib\features\articles\data\models\category_model.dart

:: articles/data/repositories/
mkdir lib\features\articles\data\repositories
echo. > lib\features\articles\data\repositories\article_repository_impl.dart

:: articles/domain/
mkdir lib\features\articles\domain

:: articles/domain/entities/
mkdir lib\features\articles\domain\entities
echo. > lib\features\articles\domain\entities\article_entity.dart
echo. > lib\features\articles\domain\entities\item_article_entity.dart

:: articles/domain/repositories/
mkdir lib\features\articles\domain\repositories
echo. > lib\features\articles\domain\repositories\article_repository.dart

:: articles/domain/usecases/
mkdir lib\features\articles\domain\usecases
echo. > lib\features\articles\domain\usecases\get_articles_usecase.dart
echo. > lib\features\articles\domain\usecases\create_article_usecase.dart
echo. > lib\features\articles\domain\usecases\update_article_usecase.dart
echo. > lib\features\articles\domain\usecases\delete_article_usecase.dart

:: articles/presentation/
mkdir lib\features\articles\presentation

:: articles/presentation/bloc/
mkdir lib\features\articles\presentation\bloc
echo. > lib\features\articles\presentation\bloc\article_bloc.dart
echo. > lib\features\articles\presentation\bloc\article_event_bloc.dart
echo. > lib\features\articles\presentation\bloc\article_state_bloc.dart

:: articles/presentation/pages/
mkdir lib\features\articles\presentation\pages
echo. > lib\features\articles\presentation\pages\article_list_page.dart
echo. > lib\features\articles\presentation\pages\article_detail_page.dart
echo. > lib\features\articles\presentation\pages\article_editor_page.dart

:: articles/presentation/widgets/
mkdir lib\features\articles\presentation\widgets
echo. > lib\features\articles\presentation\widgets\article_card.dart
echo. > lib\features\articles\presentation\widgets\article_content.dart
echo. > lib\features\articles\presentation\widgets\rich_text_editor.dart
echo. > lib\features\articles\presentation\widgets\image_picker_widget.dart

:: features/users/ (estructura similar a articles)
mkdir lib\features\users

:: users/data/
mkdir lib\features\users\data

:: users/data/datasources/
mkdir lib\features\users\data\datasources
echo. > lib\features\users\data\datasources\users_local_datasource.dart
echo. > lib\features\users\data\datasources\users_remote_datasource.dart

:: users/data/models/
mkdir lib\features\users\data\models
echo. > lib\features\users\data\models\user_model.dart
echo. > lib\features\users\data\models\item_user_model.dart
echo. > lib\features\users\data\models\role_model.dart

:: users/data/repositories/
mkdir lib\features\users\data\repositories
echo. > lib\features\users\data\repositories\users_repository_impl.dart

:: users/domain/
mkdir lib\features\users\domain

:: users/domain/entities/
mkdir lib\features\users\domain\entities
echo. > lib\features\users\domain\entities\user_entity.dart
echo. > lib\features\users\domain\entities\item_user_entity.dart

:: users/domain/repositories/
mkdir lib\features\users\domain\repositories
echo. > lib\features\users\domain\repositories\user_repository.dart

:: users/domain/usecases/
mkdir lib\features\users\domain\usecases
echo. > lib\features\users\domain\usecases\get_users_usecase.dart
echo. > lib\features\users\domain\usecases\create_user_usecase.dart
echo. > lib\features\users\domain\usecases\update_user_usecase.dart
echo. > lib\features\users\domain\usecases\delete_user_usecase.dart

:: users/presentation/
mkdir lib\features\users\presentation

:: users/presentation/bloc/
mkdir lib\features\users\presentation\bloc
echo. > lib\features\users\presentation\bloc\user_bloc.dart
echo. > lib\features\users\presentation\bloc\user_event_bloc.dart
echo. > lib\features\users\presentation\bloc\user_state_bloc.dart

:: users/presentation/pages/
mkdir lib\features\users\presentation\pages
echo. > lib\features\users\presentation\pages\user_list_page.dart
echo. > lib\features\users\presentation\pages\user_detail_page.dart
echo. > lib\features\users\presentation\pages\user_editor_page.dart

:: users/presentation/widgets/
mkdir lib\features\users\presentation\widgets
echo. > lib\features\users\presentation\widgets\user_card.dart
echo. > lib\features\users\presentation\widgets\user_content.dart
echo. > lib\features\users\presentation\widgets\user_form.dart
echo. > lib\features\users\presentation\widgets\profile_image_picker.dart

:: features/associations/ (estructura similar)
mkdir lib\features\associations

:: associations/data/
mkdir lib\features\associations\data

:: associations/data/datasources/
mkdir lib\features\associations\data\datasources
echo. > lib\features\associations\data\datasources\associations_local_datasource.dart
echo. > lib\features\associations\data\datasources\associations_remote_datasource.dart

:: associations/data/models/
mkdir lib\features\associations\data\models
echo. > lib\features\associations\data\models\association_model.dart
echo. > lib\features\associations\data\models\item_association_model.dart
echo. > lib\features\associations\data\models\type_model.dart

:: associations/data/repositories/
mkdir lib\features\associations\data\repositories
echo. > lib\features\associations\data\repositories\association_repository_impl.dart

:: associations/domain/
mkdir lib\features\associations\domain

:: associations/domain/entities/
mkdir lib\features\associations\domain\entities
echo. > lib\features\associations\domain\entities\association_entity.dart
echo. > lib\features\associations\domain\entities\item_association_entity.dart

:: associations/domain/repositories/
mkdir lib\features\associations\domain\repositories
echo. > lib\features\associations\domain\repositories\association_repository.dart

:: associations/domain/usecases/
mkdir lib\features\associations\domain\usecases
echo. > lib\features\associations\domain\usecases\get_associations_usecase.dart
echo. > lib\features\associations\domain\usecases\create_association_usecase.dart
echo. > lib\features\associations\domain\usecases\update_association_usecase.dart
echo. > lib\features\associations\domain\usecases\delete_association_usecase.dart

:: associations/presentation/
mkdir lib\features\associations\presentation

:: associations/presentation/bloc/
mkdir lib\features\associations\presentation\bloc
echo. > lib\features\associations\presentation\bloc\association_bloc.dart
echo. > lib\features\associations\presentation\bloc\association_event_bloc.dart
echo. > lib\features\associations\presentation\bloc\association_state_bloc.dart

:: associations/presentation/pages/
mkdir lib\features\associations\presentation\pages
echo. > lib\features\associations\presentation\pages\association_list_page.dart
echo. > lib\features\associations\presentation\pages\association_detail_page.dart
echo. > lib\features\associations\presentation\pages\association_editor_page.dart

:: associations/presentation/widgets/
mkdir lib\features\associations\presentation\widgets
echo. > lib\features\associations\presentation\widgets\association_card.dart
echo. > lib\features\associations\presentation\widgets\association_content.dart
echo. > lib\features\associations\presentation\widgets\association_form.dart
echo. > lib\features\associations\presentation\widgets\logo_picker_widget.dart

:: features/notifications/ (estructura similar)
mkdir lib\features\notifications

:: notifications/data/
mkdir lib\features\notifications\data

:: notifications/data/datasources/
mkdir lib\features\notifications\data\datasources
echo. > lib\features\notifications\data\datasources\notifications_local_datasource.dart
echo. > lib\features\notifications\data\datasources\notifications_remote_datasource.dart

:: notifications/data/models/
mkdir lib\features\notifications\data\models
echo. > lib\features\notifications\data\models\notification_model.dart
echo. > lib\features\notifications\data\models\item_notification_model.dart
echo. > lib\features\notifications\data\models\type_model.dart

:: notifications/data/repositories/
mkdir lib\features\notifications\data\repositories
echo. > lib\features\notifications\data\repositories\notifications_repository_impl.dart

:: notifications/domain/
mkdir lib\features\notifications\domain

:: notifications/domain/entities/
mkdir lib\features\notifications\domain\entities
echo. > lib\features\notifications\domain\entities\notification_entity.dart
echo. > lib\features\notifications\domain\entities\item_notification_entity.dart

:: notifications/domain/repositories/
mkdir lib\features\notifications\domain\repositories
echo. > lib\features\notifications\domain\repositories\notifications_repository.dart

:: notifications/domain/usecases/
mkdir lib\features\notifications\domain\usecases
echo. > lib\features\notifications\domain\usecases\get_notifications_usecase.dart
echo. > lib\features\notifications\domain\usecases\create_notification_usecase.dart
echo. > lib\features\notifications\domain\usecases\update_notification_usecase.dart
echo. > lib\features\notifications\domain\usecases\delete_notification_usecase.dart

:: notifications/presentation/
mkdir lib\features\notifications\presentation

:: notifications/presentation/bloc/
mkdir lib\features\notifications\presentation\bloc
echo. > lib\features\notifications\presentation\bloc\notifications_bloc.dart
echo. > lib\features\notifications\presentation\bloc\notification_event_bloc.dart
echo. > lib\features\notifications\presentation\bloc\notification_state_bloc.dart

:: notifications/presentation/pages/
mkdir lib\features\notifications\presentation\pages
echo. > lib\features\notifications\presentation\pages\notifications_list_page.dart
echo. > lib\features\notifications\presentation\pages\notification_detail_page.dart
echo. > lib\features\notifications\presentation\pages\notification_editor_page.dart

:: notifications/presentation/widgets/
mkdir lib\features\notifications\presentation\widgets
echo. > lib\features\notifications\presentation\widgets\notification_card.dart
echo. > lib\features\notifications\presentation\widgets\notification_content.dart
echo. > lib\features\notifications\presentation\widgets\notification_form.dart
echo. > lib\features\notifications\presentation\widgets\notification_badge.dart

:: shared/ (misma estructura que antes)
mkdir lib\shared
mkdir lib\shared\widgets
mkdir lib\shared\widgets\common
echo. > lib\shared\widgets\common\custom_app_bar.dart
echo. > lib\shared\widgets\common\custom_drawer.dart
echo. > lib\shared\widgets\common\loading_widget.dart
echo. > lib\shared\widgets\common\error_widget.dart
echo. > lib\shared\widgets\common\empty_state_widget.dart

mkdir lib\shared\widgets\forms
echo. > lib\shared\widgets\forms\custom_text_field.dart
echo. > lib\shared\widgets\forms\custom_dropdown.dart
echo. > lib\shared\widgets\forms\custom_checkbox.dart
echo. > lib\shared\widgets\forms\form_validators.dart

mkdir lib\shared\widgets\buttons
echo. > lib\shared\widgets\buttons\primary_button.dart
echo. > lib\shared\widgets\buttons\secondary_button.dart
echo. > lib\shared\widgets\buttons\icon_button.dart

mkdir lib\shared\widgets\cards
echo. > lib\shared\widgets\cards\info_card.dart
echo. > lib\shared\widgets\cards\stat_card.dart
echo. > lib\shared\widgets\cards\action_card.dart

mkdir lib\shared\models
echo. > lib\shared\models\base_model.dart
echo. > lib\shared\models\api_response.dart

mkdir lib\shared\services
echo. > lib\shared\services\cache_service.dart
echo. > lib\shared\services\notification_service.dart
echo. > lib\shared\services\storage_service.dart
echo. > lib\shared\services\analytics_service.dart

mkdir lib\shared\extensions
echo. > lib\shared\extensions\string_extensions.dart
echo. > lib\shared\extensions\datetime_extensions.dart
echo. > lib\shared\extensions\context_extensions.dart

:: injection_container.dart en raíz de lib
echo. > lib\injection_container.dart

echo Estructura de directorios y archivos creada exitosamente.
pause