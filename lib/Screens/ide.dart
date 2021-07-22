import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class IDE extends StatefulWidget {
  @override
  _IDEState createState() => _IDEState();
}

class _IDEState extends State<IDE> {
  GlobalKey<FormState> _codeKey;
  GlobalKey<FormState> _stdinKey;
  String _codeText = "";
  String _stdinText = "";
  String _stdoutText = "";
  bool _isLoading = false;
  String _url = "https://cybersaksham-apis.herokuapp.com/py_code";

  Future<void> _runCode() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_codeText == "") {
      setState(() {
        _stdoutText = "";
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final response = await http.post("$_url?code=$_codeText&stdin=$_stdinText");
    final responseData = json.decode(response.body);
    _stdoutText = responseData['out'];
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text("Code", style: TextStyle(fontSize: 20)),
            Form(
              key: _codeKey,
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                onChanged: (val) => {_codeText = val},
              ),
            ),
            SizedBox(height: 20),
            Text("Stdin", style: TextStyle(fontSize: 20)),
            Form(
              key: _stdinKey,
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                onChanged: (val) => {_stdinText = val},
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 35,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      onPressed: () => _runCode(),
                      child: Text("Run Code"),
                    ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Stdout", style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _stdoutText = "";
                    });
                  },
                  color: Theme.of(context).errorColor,
                )
              ],
            ),
            SizedBox(height: 10),
            _stdoutText == ""
                ? Container()
                : Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      _stdoutText,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
