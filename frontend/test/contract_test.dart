import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/functions.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() {
  CustomBindings();

  test('contact test', () async {
    // print(EthPrivateKey.fromHex(owner_private_key).address);
    await init();
    RequestResult result = await startMint("Moonbeam", "zhaojie44");
    print(result.value);
    print(await queryByAddress("Moonbeam", credentials.address));
  });
}
