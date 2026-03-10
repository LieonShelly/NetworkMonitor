import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'checkout_bloc.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Order')),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          if (state is CheckoutInitial) {
            context.read<CheckoutBloc>().add(LoadedCheckoutDataEvent());
            return const SizedBox.shrink();
          }
          if (state is CheckoutLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CheckoutError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          if (state is CheckoutLoaded) {
            return ListView(
              children: [
                const Text('主订单列表...'),
                if (state.showPwpSection) Text('PwpSectionWidget'),

                ElevatedButton(
                  onPressed: () {
                    context.read<CheckoutBloc>().add(
                      const SelectVoucherEvent(true),
                    );
                  },
                  child: const Text('选择互斥优惠券'),
                ),
              ],
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
