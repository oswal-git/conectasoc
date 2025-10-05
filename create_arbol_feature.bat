@echo off
setlocal

echo Creando estructura de directorios y archivos en lib\features\home


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
echo. > lib\features\home\presentation\pages\home_page.dart

:: home/presentation/widgets/
mkdir lib\features\home\presentation\widgets
echo. > lib\features\home\presentation\widgets\home_card.dart
echo. > lib\features\home\presentation\widgets\home_content.dart
echo. > lib\features\home\presentation\widgets\rich_text_editor.dart
echo. > lib\features\home\presentation\widgets\image_picker_widget.dart

echo Estructura de directorios y archivos creada exitosamente.
pause