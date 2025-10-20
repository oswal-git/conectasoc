import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/associations/domain/usecases/get_all_associations_usecase.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final GetAllAssociationsUseCase getAllAssociationsUseCase;

  RegisterBloc({required this.getAllAssociationsUseCase})
      : super(RegisterInitial()) {
    on<LoadRegisterData>(_onLoadRegisterData);
  }

  Future<void> _onLoadRegisterData(
    LoadRegisterData event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    final result = await getAllAssociationsUseCase();
    result.fold(
      (failure) => emit(RegisterError(failure.message)),
      (associations) {
        // For now, isFirstUser is always false as per previous logic.
        emit(RegisterDataLoaded(
          associations: associations,
          isFirstUser: false,
        ));
      },
    );
  }
}
