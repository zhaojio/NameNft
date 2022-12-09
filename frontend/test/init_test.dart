import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/functions.dart';
import 'package:web3dart/web3dart.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() {
  CustomBindings();

  test('init test', () async {
    // print(EthPrivateKey.fromHex(owner_private_key).address);
    await init();
  });
}
