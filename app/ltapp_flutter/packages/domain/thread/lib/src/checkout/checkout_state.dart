import 'package:equatable/equatable.dart';

class PwpActivityEntity {
  const PwpActivityEntity();
}

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutInitial extends CheckoutState {}

final class CheckoutLoading extends CheckoutState {}

final class CheckoutLoaded extends CheckoutState {
  final PwpActivityEntity pwpActivityEntity;
  final bool showPwpSection;

  const CheckoutLoaded({
    required this.pwpActivityEntity,
    this.showPwpSection = true,
  });

  @override
  List<Object?> get props => [pwpActivityEntity, showPwpSection];
}

final class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}
