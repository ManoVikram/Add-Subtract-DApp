import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add And Subtract',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Add And Subtract DApp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int balance = 0;
  bool loading = false;

  final String rpcURL = "http://127.0.0.1:7545";
  final String contractName = "AddAndSubtract";
  final String privateKey =
      "";

  late Client httpClient;
  late Web3Client ethClient;
  late Credentials credentials;
  late EthereumAddress address;
  late String abi;
  late EthereumAddress contractAddress;
  late DeployedContract contract;
  late ContractFunction add, subtract, getNumber;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(rpcURL, httpClient);
    getBalance();
  }

  Future<DeployedContract> getContract() async {
    String abiString = await rootBundle
        .loadString("contracts/build/contracts/AddAndSubtract.json");
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson["abi"]);

    contractAddress =
        EthereumAddress.fromHex("0x0b91D8E23079B20ABfCd50F8C892096f967f35DD");

    contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      contractAddress,
    );

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    contract = await getContract();
    ContractFunction function = contract.function(functionName);
    List<dynamic> result = await ethClient.call(
      contract: contract,
      function: function,
      params: args,
    );

    return result;
  }

  Future<String> transaction(String functionName, List<dynamic> args) async {
    credentials = EthPrivateKey.fromHex(privateKey);
    ContractFunction function = contract.function(functionName);
    dynamic result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: args,
      ),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );

    return result;
  }

  Future<void> getBalance() async {
    setState(() {
      loading = true;
    });

    List<dynamic> result = await query("balance", []);
    balance = int.parse(result[0].toString());
    print(balance);

    setState(() {
      loading = false;
    });
  }

  Future<void> addValue() async {
    var result = await transaction("add", []);
    print("Added!");
    print(result);
  }

  Future<void> subtractValue() async {
    var result = await transaction("subtract", []);
    print("Subtracted!");
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Balance:',
            ),
            loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Text(
                    "$balance",
                    style: Theme.of(context).textTheme.headline4,
                  ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: subtractValue,
            tooltip: "Decrement",
            child: const Icon(Icons.remove),
          ),
          FloatingActionButton(
            onPressed: addValue,
            tooltip: "Increment",
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: getBalance,
            tooltip: "Get Value",
            child: const Icon(Icons.done),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
