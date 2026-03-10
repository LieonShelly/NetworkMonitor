import 'package:equatable/equatable.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

// 页面初始化，请求数据的事件
final class LoadedCheckoutDataEvent extends CheckoutEvent {}

// 点击 Add 的事件
final class AddPwpItemEvent extends CheckoutEvent {
  final String productId;

  const AddPwpItemEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

// 用户选择了一张互斥的优惠券的事件
final class SelectVoucherEvent extends CheckoutEvent {
  final bool isMutuallyExclusive;

  const SelectVoucherEvent(this.isMutuallyExclusive);

  @override
  List<Object?> get props => [isMutuallyExclusive];
}
