import 'package:flutter/material.dart';
import 'package:frontend/services/functions.dart';

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
  bool inined = false;

  // Initial Selected Value
  var dropDownValue;

  @override
  void initState() {
    super.initState();
    init().then((value) {
      setState(() => inined = true);
      dropDownValue = chainInfos[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !inined
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
                    const Expanded(child: Text('')),
                    TextButton(
                        onPressed: () {},
                        child: Text(credentials.address.toString())),
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
                  width: 550,
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                                onSubmitted: (value) {
                                  print(value);
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
                                onPressed: () async {
                                  var res =
                                      await queryByName("Moonbeam", "zhaojie");
                                  print(res);
                                },
                                child: const Text(
                                  "Minting",
                                  style: TextStyle(fontSize: 17),
                                ))
                          ]),
                      const SizedBox(height: 20),
                      const Text('Minting....',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      const Align(
                          alignment: Alignment.topLeft, child: Text("My Nfts")),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 550,
                      child: GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1 / 1,
                        children: [
                          Container(
                              color: Colors.green,
                              child: Center(child: Text("data"))),
                          Container(
                              color: Colors.green,
                              child: Center(child: Text("data"))),
                          Container(
                              color: Colors.green,
                              child: Center(child: Text("data"))),
                          Container(
                              color: Colors.green,
                              child: Center(child: Text("data"))),
                          Container(
                              color: Colors.green,
                              child: Center(child: Text("data"))),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
