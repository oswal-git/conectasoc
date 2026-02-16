@echo off
setlocal

echo Creando estructura de directorios y archivos en lib\features\documents


:: features/documents/
mkdir lib\features\documents

:: documents/data/
mkdir lib\features\documents\data

:: documents/data/datasources/
mkdir lib\features\documents\data\datasources
rem echo. > lib\features\documents\data\datasources\documents_local_datasource.dart
echo. > lib\features\documents\data\datasources\document_remote_datasource.dart

:: documents/data/models/
mkdir lib\features\documents\data\models
echo. > lib\features\documents\data\models\document_model.dart
rem echo. > lib\features\documents\data\models\item_documents_model.dart
rem echo. > lib\features\documents\data\models\category_model.dart
echo "export 'document_model.dart'" > lib\features\documents\data\models\models.dart

:: documents/data/repositories/
mkdir lib\features\documents\data\repositories
echo. > lib\features\documents\data\repositories\document_repository_impl.dart

:: documents/domain/
mkdir lib\features\documents\domain

:: documents/domain/entities/
mkdir lib\features\documents\domain\entities
echo. > lib\features\documents\domain\entities\document_entity.dart
echo. > lib\features\documents\domain\entities\document_link_entity.dart
echo "export 'document_entity.dart'" > lib\features\documents\domain\entities\entities.dart
echo "export 'document_link_entity.dart'" >> lib\features\documents\domain\entities\entities.dart

:: documents/domain/repositories/
mkdir lib\features\documents\domain\repositories
echo. > lib\features\documents\domain\repositories\document_repository.dart

:: documents/domain/usecases/
mkdir lib\features\documents\domain\usecases
echo. > lib\features\documents\domain\usecases\create_document_usecase.dart
echo. > lib\features\documents\domain\usecases\delete_document_usecase.dart
echo. > lib\features\documents\domain\usecases\get_document_by_id_usecase.dart
echo. > lib\features\documents\domain\usecases\get_document_by_asaociation_usecase.dart
echo. > lib\features\documents\domain\usecases\search_document_usecase.dart
echo "export 'create_document_usecase.dart'" > lib\features\documents\domain\usecases\usecases.dart
echo "export 'delete_document_usecase.dart'" >> lib\features\documents\domain\usecases\usecases.dart
echo "export 'get_document_by_id_usecase.dart'" >> lib\features\documents\domain\usecases\usecases.dart
echo "export 'get_document_by_asaociation_usecase.dart'" >> lib\features\documents\domain\usecases\usecases.dart
echo "export 'search_document_usecase.dart'" >> lib\features\documents\domain\usecases\usecases.dart

:: documents/presentation/
mkdir lib\features\documents\presentation

:: documents/presentation/bloc/
mkdir lib\features\documents\presentation\bloc
mkdir lib\features\documents\presentation\bloc\search
mkdir lib\features\documents\presentation\bloc\upload
echo. > lib\features\documents\presentation\bloc\document_bloc.dart
echo. > lib\features\documents\presentation\bloc\document_event_bloc.dart
echo. > lib\features\documents\presentation\bloc\document_state_bloc.dart
echo. > lib\features\documents\presentation\bloc\upload\document_upload_bloc.dart
echo. > lib\features\documents\presentation\bloc\upload\document_upload_event_bloc.dart
echo. > lib\features\documents\presentation\bloc\upload\document_upload_state_bloc.dart
echo. > lib\features\documents\presentation\bloc\search\document_search_bloc.dart
echo. > lib\features\documents\presentation\bloc\search\document_search_event_bloc.dart
echo. > lib\features\documents\presentation\bloc\search\document_search_state_bloc.dart
echo export "document_bloc.dart" > lib\features\documents\presentation\bloc\bloc.dart
echo export "document_event_bloc.dart" >> lib\features\documents\presentation\bloc\bloc.dart
echo export "document_state_bloc.dart" >> lib\features\documents\presentation\bloc\bloc.dart
echo export "upload\document_upload_bloc.dart" >> lib\features\documents\presentation\bloc\bloc.dart
echo export "upload\document_upload_event_bloc.dart" >> lib\features\documents\presentation\bloc\bloc.dart
echo export "upload\document_upload_state_bloc.dart" >> lib\features\documents\presentation\bloc\bloc.dart
echo export "search\document_search_bloc.dart'" >> lib\features\documents\presentation\bloc\bloc.dart
echo export "search\document_search_event_bloc.dart'" >> lib\features\documents\presentation\bloc\bloc.dart
echo export "search\document_search_state_bloc.dart'" >> lib\features\documents\presentation\bloc\bloc.dart

:: documents/presentation/pages/
mkdir lib\features\documents\presentation\pages
echo. > lib\features\documents\presentation\pages\documents_list_page.dart
echo. > lib\features\documents\presentation\pages\documents_upload_page.dart
echo "export 'documents_list_page.dart'" > lib\features\documents\presentation\pages\pages.dart
echo "export 'documents_upload_page.dart'" >> lib\features\documents\presentation\pages\pages.dart

:: documents/presentation/widgets/
mkdir lib\features\documents\presentation\widgets
echo. > lib\features\documents\presentation\widgets\document_picker_widget.dart
echo. > lib\features\documents\presentation\widgets\document_search_dialog.dart
echo. > lib\features\documents\presentation\widgets\document_thumbnail_widget.dart
echo. > lib\features\documents\presentation\widgets\document_viewer_widget.dart
echo "export 'document_picker_widget.dart'" > lib\features\documents\presentation\widgets\widgets.dart
echo "export 'document_search_dialog.dart'" >> lib\features\documents\presentation\widgets\widgets.dart
echo "export 'document_thumbnail_widget.dart'" >> lib\features\documents\presentation\widgets\widgets.dart
echo "export 'document_viewer_widget.dart'" >> lib\features\documents\presentation\widgets\widgets.dart

echo Estructura de directorios y archivos creada exitosamente.
pause