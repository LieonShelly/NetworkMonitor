// import 'package:http/http.dart';
// import 'package:web3dart/web3dart.dart';

// class ChainService {
//   static const String rpcUrl = "https://ethereum-sepolia-rpc.publicnode.com";

//   late Web3Client _client;

//   ChainService() {
//     _client = Web3Client(rpcUrl, Client());
//   }

//   Future<double> getBalance(String addressHex) async {
//     try {
//       final address = EthereumAddress.fromHex(addressHex);
//       final balanceInWei = await _client.getBalance(address);
//       return balanceInWei.getValueInUnit(EtherUnit.ether);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
