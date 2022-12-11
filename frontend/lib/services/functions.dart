import 'dart:async';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';

late List chainInfos;
late EthPrivateKey credentials;

enum PayloadType {
  minting,
  query,
  response,
  authorization,
  deauthorization,
  transfer
}

enum MessageResult { success, fail }

class RequestResult {
  bool result;
  var value;

  RequestResult(this.result, this.value);
}

//读取文件
Future init() async {
  //../info/local.json
  // var strContract = await File("../artifacts/examples/nft-name/NftName.sol/NameNft.json").readAsString();
  // var strInfo = await File("../info/local.json").readAsString();
  var strContract = await rootBundle.loadString('assets/NameNft.json');
  var strInfo = await rootBundle.loadString("assets/local.json");

  chainInfos = await jsonDecode(strInfo);

  var strAbi = await jsonDecode(strContract)["abi"];
  strAbi = jsonEncode(strAbi);
  ContractAbi abi = ContractAbi.fromJson(strAbi, 'Election');

  chainInfos.forEach((element) {
    var contractAddress = element['NftName'];
    element['contract'] =
        DeployedContract(abi, EthereumAddress.fromHex(contractAddress));
    element['web3Client'] = Web3Client(element['rpc'], Client());
  });

  //读取.env
  // var env = await File("../.env").readAsString();
  var env = await rootBundle.loadString("assets/.env");
  credentials = EthPrivateKey.fromHex(env.split("=")[1].trim());
  return true;
}

Future queryByName(String chainName, String name) async {
  var response = await ask('queryByName', [name], getChainByName(chainName));
  return response[0];
}

Future<RequestResult> queryByAddress(
    String chainName, EthereumAddress addr) async {
  var chain = getChainByName(chainName);
  try {
    var response = await ask('queryByAddress', [addr], chain);
    List res = response[0];
    if (res.isNotEmpty) return RequestResult(true, res);
    return RequestResult(false, "null");
  } catch (_) {
    return RequestResult(false, "Rpc Error");
  }
}

String formatAddress() {
  String strAddr = credentials.address.toString();
  return "${strAddr.substring(0, 6)}...${strAddr.substring(strAddr.length - 4, strAddr.length)}";
}

Future<RequestResult> startMint(String chainName, String name) async {
  //生成msgId
  int msgId = DateTime.now().microsecondsSinceEpoch;
  var chain = getChainByName(chainName);
  Web3Client web3client = chain['web3Client'];
  // Web3Client web3client = Web3Client(chain['rpc'], Client());
  // Web3Client web3client = chain['web3Client'];
  DeployedContract contract = chain['contract'];
  Completer<RequestResult> completer = Completer();

  web3client.events(FilterOptions(address: contract.address)).listen((event) {
    print(event);
    int _msgId = int.parse(event.topics![1]);
    if (_msgId == msgId) {
      int payloadType = int.parse(event.topics![2]);
      int messageResult = int.parse(event.topics![3]);
      if (payloadType == PayloadType.minting.index) {
        if (messageResult == MessageResult.success.index) {
          completer.complete(RequestResult(true, ""));
        } else {
          completer.complete(
              RequestResult(false, "Name has been used on other chain"));
        }
        // web3client.dispose();
      }
    }
  });

  try {
    await call(
        'startMint', [name, BigInt.from(msgId)], getChainByName(chainName));
  } catch (e) {
    completer.complete(RequestResult(false, e.toString()));
  }
  return Future.any([
    completer.future,
    Future.delayed(const Duration(seconds: 10))
        .then((value) => Future.value(RequestResult(false, "TimeOut")))
  ]);
}

getChainByName(String chainName) {
  return chainInfos.where((element) => element['name'] == chainName).first;
}

Future<String> call(String funcname, List<dynamic> args, var chainInfo) async {
  Web3Client ethClient = chainInfo['web3Client'];
  DeployedContract contract = chainInfo['contract'];
  final ethFunction = contract.function(funcname);
  final gasPrice = await ethClient.getGasPrice();
  final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        value:
            EtherAmount.inWei(BigInt.from(10 * gasPrice.getInWei.toDouble())),
        parameters: args,
      ),
      chainId: null,
      fetchChainIdFromNetworkId: true);
  return result;
}

Future<List<dynamic>> ask0(
    String funcName, List<dynamic> args, var chainInfo) async {
  return (await ask(funcName, args, chainInfo))[0];
}

Future<List<dynamic>> ask(
    String funcName, List<dynamic> args, var chainInfo) async {
  final contract = chainInfo['contract'];
  final ethFunction = contract.function(funcName);
  final result = chainInfo['web3Client']
      .call(contract: contract, function: ethFunction, params: args);
  return result;
}
