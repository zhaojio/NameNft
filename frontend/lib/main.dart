import 'package:flutter/material.dart';
import 'package:frontend/services/functions.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NameNft Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'NameNft Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchController = TextEditingController();

  String searchText = '';

  bool inited = false;
  bool isMinting = false;

  // Initial Selected Value
  var dropDownValue;
  String msg = '';
  Map myNfts = {};
  bool loadMyNfts = false;

  @override
  void initState() {
    super.initState();
    init().then((value) {
      setState(() => inited = true);
      dropDownValue = chainInfos[0];
      _loadAllNfts();
    });
  }

  _startMinting() {
    if (isMinting) return;
    setState(() {
      msg =
          "Minting name:$searchText on the chain ${dropDownValue['name']}....";
    });
    startMint(dropDownValue['name'], searchText).then((value) {
      if (value.result) {
        msg =
            "Minting name:$searchText on the chain ${dropDownValue['name']} success";
        _loadAllNfts();
      } else {
        msg = "Minting name:$searchText fail!!! ${value.value}";
      }
      setState(() {});
    });
  }

  Future _loadAllNfts() async {
    setState(() {
      loadMyNfts = true;
      myNfts = {};
    });
    for (var chain in chainInfos) {
      RequestResult result =
          await queryByAddress(chain['name'], credentials.address);
      if (result.result) {
        for (var element in (result.value as List)) {
          NameNft? nameNft;
          if (myNfts.containsKey(element[0])) {
            nameNft = myNfts[element[0]];
            if (element[2]) {
              nameNft!.ownerShip = chain['name'];
            } else if (element[3]) {
              nameNft!.useRightChains.add(chain['name']);
            }
          } else {
            if (element[2]) {
              //isOwner
              nameNft = NameNft(element[0], element[1], chain['name'], []);
            } else if (element[3]) {
              //isRightToUse
              nameNft = NameNft(element[0], element[1], '', [chain['name']]);
            }
          }
          myNfts[element[0]] = nameNft;
        }
      }
    }
    setState(() {
      loadMyNfts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !inited
          ? const Center(
              child: Text("loading...."),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    TextButton(
                        onPressed: _changeAccount,
                        child: Text(
                          formatAddress(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(
                      width: 60,
                    )
                  ],
                ),
                const Text(
                  'Hackathon: The Illuminate/22 Hack by Moonbeam \r\nUse Axelar’s General Message Passing (GMP) Feature',
                ),
                const SizedBox(height: 20),
                const Text("NameNft",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Mint once use everywhere"),
                const SizedBox(height: 10),
                const Text(
                    "Supported chains: Moonbeam Avalanche Fantom Ethereum Polygon"),
                const SizedBox(height: 40),
                SizedBox(
                  width: 580,
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  searchText = value;
                                },
                                onSubmitted: (value) {
                                  searchText = value;
                                  _startMinting();
                                },
                                controller: searchController,
                                decoration: InputDecoration(
                                  suffixIcon: Offstage(
                                    offstage: searchText.isEmpty ? true : false,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          searchText = '';
                                          searchController
                                              .clear(); //清除textfield的值
                                        });
                                      },
                                      child: const Icon(Icons.close),
                                    ),
                                  ),
                                  // labelText: '表单label',
                                  hintText: 'Enter a username you wish to mint',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            DropdownButton(
                              value: dropDownValue,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: chainInfos.map((items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items['name']),
                                );
                              }).toList(),
                              underline: Container(height: 0),
                              onChanged: (newValue) {
                                setState(() {
                                  dropDownValue = newValue;
                                });
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              },
                            ),
                            // const SizedBox(width: 5),
                            TextButton(
                                onPressed: _startMinting,
                                child: const Text(
                                  "Minting",
                                  style: TextStyle(fontSize: 17),
                                ))
                          ]),
                      const SizedBox(height: 30),
                      Text(msg),
                      const SizedBox(height: 20),
                      const Align(
                          alignment: Alignment.topLeft, child: Text("My Nfts")),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                myNfts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          loadMyNfts ? "Loading..." : "No Nfts",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : Expanded(
                        child: Center(
                          child: SizedBox(
                            width: 600,
                            child: GridView.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 20,
                              childAspectRatio: 1 / 1,
                              children: myNfts.entries
                                  .map((e) => buildNftCard(e.value))
                                  .toList(),
                            ),
                          ),
                        ),
                      )
              ],
            ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildNftCard(NameNft nft) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Center(
                      child: Text(nft.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    const SizedBox(height: 10),
                    Text("Ownership: ${nft.ownerShip}"),
                    const SizedBox(height: 5),
                    Offstage(
                      offstage: nft.useRightChains.isEmpty,
                      child: Text(
                          "Right to use: ${nft.useRightChains.isEmpty ? "" : nft.useRightChains.reduce((value, element) => value + " " + element)}"),
                    ),
                    // const SizedBox(height: 5),
                    // const Text(" "),
                  ]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => _authorize(nft),
                  child: const Text("Authorize")),
              TextButton(
                  onPressed: () => _transfer(nft),
                  child: const Text("Transfer")),
              const Padding(padding: EdgeInsets.only(right: 5)),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  _changeAccount() {
    ValueNotifier<String> valueNotifier = ValueNotifier("");
    String inputValue = '';
    setNewAddress() {
      EthPrivateKey? privateKey = EthPrivateKey.fromHex(inputValue);
      if (privateKey != credentials) {
        credentials = privateKey;
      }
      _loadAllNfts();
    }

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Change Account"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 600,
                    child: TextField(
                      onChanged: (value) {
                        if (!value.startsWith("0x")) value = "0x$value";
                        inputValue = value;
                        if (inputValue.length != 66) {
                          return;
                          // valueNotifier.value = "Error Key!";
                        }
                        valueNotifier.value =
                            "Address:${EthPrivateKey.fromHex(inputValue).address.toString()}";
                      },
                      decoration:
                          const InputDecoration(hintText: "Input private key"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    builder: (BuildContext context, value, Widget? child) {
                      return Text(value);
                    },
                    valueListenable: valueNotifier,
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
                TextButton(
                    onPressed: () {
                      if (inputValue.length != 66) {
                        valueNotifier.value = "Error Key!";
                        return;
                      }
                      setNewAddress();
                      Navigator.pop(ctx);
                    },
                    child: const Text("Confirm")),
              ],
            ));
  }

  _transfer(NameNft nft) {
    String inputAddress = '';
    EthereumAddress address = nft.addr;

    ValueNotifier<bool> isTransferring = ValueNotifier(false);
    ValueNotifier _dropDownValue = ValueNotifier(chainInfos[0]);

    startTransfer() async {
      if (inputAddress.isNotEmpty) {
        address = EthereumAddress.fromHex(inputAddress);
      }
      try {
        await call(
            'transfer',
            [address, _dropDownValue.value['name'], nft.name, BigInt.from(0)],
            getChainByName(nft.ownerShip));
      } catch (_) {
        return false;
      }

      int waitCount = 0;
      List res = await ask0("queryByName", [nft.name], _dropDownValue.value);

      while (!(res[1] == address && res[2] == true) && waitCount < 10) {
        await Future.delayed(const Duration(seconds: 1));
        waitCount++;
        res = await ask0("queryByName", [nft.name], _dropDownValue.value);
      }

      if (res[1] == address) {
        _loadAllNfts();
      }
      return res[1] == address;
    }

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("Transfer ${nft.name}"),
            content: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 400,
                  child: TextField(
                    onChanged: (value) {
                      inputAddress = value;
                    },
                    decoration: InputDecoration(hintText: nft.addr.toString()),
                  ),
                ),
                const SizedBox(width: 20),
                ValueListenableBuilder(
                  valueListenable: _dropDownValue,
                  builder: (BuildContext context, value, Widget? child) {
                    return DropdownButton(
                      value: _dropDownValue.value,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: chainInfos.map((items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items['name']),
                        );
                      }).toList(),
                      underline: Container(height: 0),
                      onChanged: (newValue) {
                        _dropDownValue.value = newValue;
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    if (isTransferring.value) return;
                    isTransferring.value = true;
                    startTransfer().then((value) => Navigator.pop(ctx));
                  },
                  child: ValueListenableBuilder(
                    builder: (BuildContext context, value, Widget? child) {
                      return Text(value ? "Transferring..." : "Transfer");
                    },
                    valueListenable: isTransferring,
                  )),
            ],
          );
        });
  }

  _authorize(NameNft nft) {
    String inputAddress = '';
    EthereumAddress address = nft.addr;

    List _chainInfos =
        chainInfos.where((e) => e['name'] != nft.ownerShip).toList();

    ValueNotifier<bool> isAuthing = ValueNotifier(false);
    ValueNotifier _dropDownValue = ValueNotifier(_chainInfos[0]);

    startTransfer() async {
      if (inputAddress.isNotEmpty) {
        address = EthereumAddress.fromHex(inputAddress);
      }
      try {
        await call(
            'authorization',
            [address, _dropDownValue.value['name'], nft.name, BigInt.from(0)],
            getChainByName(nft.ownerShip));
      } catch (_) {
        return false;
      }

      int waitCount = 0;
      List res = await ask0("queryByName", [nft.name], _dropDownValue.value);

      while (res[1] != address && waitCount < 10) {
        await Future.delayed(const Duration(seconds: 1));
        waitCount++;
        res = await ask0("queryByName", [nft.name], _dropDownValue.value);
      }

      if (res[1] == address) {
        _loadAllNfts();
      }
      return res[1] == address;
      //修改nftlist
    }

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("Authorize ${nft.name}"),
            content: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 400,
                  child: TextField(
                    onChanged: (value) {
                      inputAddress = value;
                    },
                    decoration: InputDecoration(hintText: nft.addr.toString()),
                  ),
                ),
                const SizedBox(width: 20),
                ValueListenableBuilder(
                  valueListenable: _dropDownValue,
                  builder: (BuildContext context, value, Widget? child) {
                    return DropdownButton(
                      value: _dropDownValue.value,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _chainInfos.map((items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items['name']),
                        );
                      }).toList(),
                      underline: Container(height: 0),
                      onChanged: (newValue) {
                        _dropDownValue.value = newValue;
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    if (isAuthing.value) return;
                    isAuthing.value = true;
                    startTransfer().then((value) {
                      Navigator.pop(ctx);
                    });
                  },
                  child: ValueListenableBuilder(
                    builder: (BuildContext context, value, Widget? child) {
                      return Text(value ? "Authorizing..." : "Authorize");
                    },
                    valueListenable: isAuthing,
                  )),
            ],
          );
        });
  }
}

class NameNft {
  String name;
  EthereumAddress addr;
  String ownerShip;
  List useRightChains;

  NameNft(this.name, this.addr, this.ownerShip, this.useRightChains);
}
