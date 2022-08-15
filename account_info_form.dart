import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:<project name>/account_list_scaffold.dart';

/// A form to allow a user to enter (and persist)
/// information to make API calls work
class InfluxDBAccountInfoForm extends StatefulWidget {
  final AccountInfo? account;

  /// Create an instance of a form using an instance of args
  const InfluxDBAccountInfoForm({Key? key, this.account}) : super(key: key);

  @override
  InfluxDBAccountInfoFormState createState() => InfluxDBAccountInfoFormState();
}

class InfluxDBAccountInfoFormState extends State<InfluxDBAccountInfoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  AccountInfo? account;

  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    // set up the account info
    if (widget.account != null) {
      account = widget.account;
    } else {
      account = AccountInfo();
      account!.accountName = "New Account";
    }
    _accountNameController.text =
        account!.accountName == null ? "" : account!.accountName.toString();
    _orgController.text =
        account!.orgName == null ? "" : account!.orgName.toString();
    _urlController.text = account!.url == null ? "" : account!.url.toString();
    _tokenController.text =
        account!.token == null ? "" : account!.token.toString();
    account!.active = account!.active ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                _formKey.currentState?.save();
                account!.saveToStorage();
                Navigator.pop(context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountNameController,
                decoration: (const InputDecoration(labelText: "Account Name")),
                onSaved: (String? value) {
                  account!.accountName = value.toString();
                },
              ),
              TextFormField(
                controller: _orgController,
                decoration:
                    (const InputDecoration(labelText: "Organization Name")),
                onSaved: (String? value) {
                  account!.orgName = value.toString();
                },
              ),
              TextFormField(
                controller: _urlController,
                decoration: (const InputDecoration(labelText: "URL")),
                onSaved: (String? value) {
                  account!.url = value.toString();
                },
              ),
              TextFormField(
                controller: _tokenController,
                decoration: (const InputDecoration(labelText: "Token")),
                obscureText: true,
                onSaved: (String? value) {
                  account!.token = value.toString();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
