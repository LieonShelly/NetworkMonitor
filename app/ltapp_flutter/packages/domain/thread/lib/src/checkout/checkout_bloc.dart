import 'package:flutter_bloc/flutter_bloc.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

abstract interface class GetCheckoutDataUseCase {
  Future<PwpActivityEntity> execute();
}

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  // usecase 抽象接口
  final GetCheckoutDataUseCase _getCheckoutDataUseCase;

  CheckoutBloc({required GetCheckoutDataUseCase getCheckoutDataUseCase})
    : _getCheckoutDataUseCase = getCheckoutDataUseCase,
      super(CheckoutInitial()) {
    on<LoadedCheckoutDataEvent>(_onLoadData);
    on<SelectVoucherEvent>(_onSelectVoucher);
  }

  Future<void> _onLoadData(
    LoadedCheckoutDataEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final activityData = await _getCheckoutDataUseCase.execute();
    emit(CheckoutLoaded(pwpActivityEntity: activityData, showPwpSection: true));
    try {} catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  void _onSelectVoucher(SelectVoucherEvent event, Emitter<CheckoutState> emit) {
    if (state is CheckoutLoaded) {
      final currentState = state as CheckoutLoaded;
      final shouldShowPwp = !event.isMutuallyExclusive;

      emit(
        CheckoutLoaded(
          pwpActivityEntity: currentState.pwpActivityEntity,
          showPwpSection: shouldShowPwp,
        ),
      );
    }
  }
}
