// import 'package:flutter/widgets.dart';
// import 'package:chain_service/chain_service.dart';

// class BalancePage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _BalancePageState();
//   }
// }

// class _BalancePageState extends State<BalancePage> {
//   final _chainService = ChainService();
//   final _addressController = TextEditingController(text: '0x你的地址');

//   String _balanceDisplay = "点击查询";
//   bool _isLoading = false;

//   Future<void> _fetchBalance() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final balance = await _chainService.getBalance(_addressController.text);
//       setState(() {
//         _balanceDisplay = "${balance.toStringAsFixed(4)} SepoliaETH";
//       });
//     } catch (e) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text("data"));
//   }
// }
