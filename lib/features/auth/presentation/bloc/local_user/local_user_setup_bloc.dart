import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalUserSetupBloc
    extends Bloc<LocalUserSetupEvent, LocalUserSetupState> {
  final GetAllAssociationsUseCase _getAllAssociationsUseCase;

  LocalUserSetupBloc(
      {required GetAllAssociationsUseCase getAllAssociationsUseCase})
      : _getAllAssociationsUseCase = getAllAssociationsUseCase,
        super(LocalUserSetupInitial()) {
    on<LoadAssociations>(_onLoadAssociations);
  }

  Future<void> _onLoadAssociations(
    LoadAssociations event,
    Emitter<LocalUserSetupState> emit,
  ) async {
    emit(LocalUserSetupLoading());
    final result = await _getAllAssociationsUseCase();
    result.fold(
      (failure) => emit(LocalUserSetupError(failure.message)),
      (associations) => emit(LocalUserSetupLoaded(associations)),
    );
  }
}
