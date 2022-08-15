import 'package:flutter/material.dart';
import 'package:<project name>/account_list_scaffold.dart';
import 'package:influxdb_client/api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfluxDB Boiler Plate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'InfluxDB Boiler Plate'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // The info about all of the InfluxDB instances that the user has set up
  // You can pass this around to whatever needs the info
  AccountList accountList = AccountList();
  InfluxDBClient client = InfluxDBClient();

  @override
  void initState() {
    loadFromStorage();
    super.initState();
  }

  loadFromStorage() async {
    await accountList.loadFromStorage();
    client = InfluxDBClient(
        url: accountList.activeAccount!.url,
        bucket: "operating",
        org: accountList.activeAccount!.orgName,
        token: accountList.activeAccount!.token);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            accountList.activeAccount == null
                ? "Select or Create an Account"
                : accountList.activeAccount!.accountName.toString(),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((BuildContext context) {
                        return const Dialog(
                          child: AccountListScaffold(),
                        );
                      }),
                    ),
                  );
                  await accountList.loadFromStorage();
                  setState(() {});
                },
                icon: const Icon(Icons.person))
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text("InfluxDB Boiler Plate"),
          ],
        ),
      ),
    );
  }
}
