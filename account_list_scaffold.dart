import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'account_info_form.dart';

class AccountInfo {
  String? _accountName;
  String _oldAccountName = "";

  String? get accountName => _accountName;

  set accountName(String? accountName) {
    _oldAccountName = _accountName.toString();
    _accountName = accountName;
  }

  String? orgName;
  String? url;
  String? token;
  bool? active;

  AccountInfo(
      {String? accountName, this.orgName, this.url, this.token, this.active}) {
    _accountName = accountName;
  }

  void saveToStorage() {
    FlutterSecureStorage storage = const FlutterSecureStorage();

    // this allows the user to change the name of the account
    if (_accountName != _oldAccountName) {
      storage.delete(key: _oldAccountName);
      _oldAccountName = _accountName.toString();
    }

    // this stores the account in the secrete storage
    String jsonBlob = jsonEncode(
        {"orgName": orgName, "url": url, "token": token, "active": active});
    storage.write(key: accountName.toString(), value: jsonBlob);
  }
}

class AccountList extends ListBase<AccountInfo> {
  final List<AccountInfo> _accounts = [];

  @override
  int get length => _accounts.length;

  @override
  AccountInfo operator [](int index) {
    return _accounts[index];
  }

  @override
  void operator []=(int index, AccountInfo value) {
    _accounts[index] = value;
  }

  @override
  set length(int newLength) {
    _accounts.length = newLength;
  }

  AccountInfo? get activeAccount {
    for (AccountInfo account in _accounts) {
      if (account.active!) {
        debugPrint("Active: ${account.accountName}");
        return account;
      }
    }
    return null;
  }

  loadFromStorage() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    _accounts.clear();
    Map<String, String> accounts = await storage.readAll();

    for (var element in accounts.entries) {
      Map<String, dynamic> settings = jsonDecode(element.value);
      debugPrint(element.toString());
      _accounts.add(AccountInfo(
          accountName: element.key,
          orgName: settings["orgName"],
          url: settings["url"],
          token: settings["token"],
          active: settings["active"]));
    }
  }

  void setActiveAccount(AccountInfo account) {
    // set all of the acconunts to inactive
    // then set the active account to active
    // dirty but easy to read :)
    for (AccountInfo a in _accounts) {
      a.active = false;
      a.saveToStorage();
    }
    account.active = true;
    account.saveToStorage();
  }
}

class AccountListScaffold extends StatefulWidget {
  const AccountListScaffold({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AccountListScaffoldState();
}

class AccountListScaffoldState extends State<AccountListScaffold> {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  AccountList accountList = AccountList();

  @override
  void initState() {
    loadFromStorage();
    super.initState();
  }

  loadFromStorage() async {
    await accountList.loadFromStorage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
        actions: <Widget>[
          // This button is here for debugging purposes
          IconButton(
              onPressed: (() {
                FlutterSecureStorage storage = const FlutterSecureStorage();
                storage.deleteAll();
              }),
              icon: const Icon(Icons.delete_forever))
        ],
      ),
      body: ListView.builder(
          itemCount: accountList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(accountList[index].accountName.toString()),
              leading: Checkbox(
                value: accountList[index].active,
                onChanged: (bool? value) {
                  setState(() {
                    accountList[index].active = value;
                    accountList.setActiveAccount(accountList[index]);
                  });
                },
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Dialog(
                        child: InfluxDBAccountInfoForm(
                          account: accountList[index],
                        ),
                      );
                    },
                  ),
                );
                loadFromStorage();
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Dialog(
                  child: InfluxDBAccountInfoForm(),
                );
              },
            ),
          );
          loadFromStorage();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
