//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/mainscreensocstaff.dart';
import 'package:final_project/registrationscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
//import 'package:http/http.dart' as http;
//import 'package:progress_dialog/progress_dialog.dart';
import 'user.dart';

String urlLogin = "https://limmuihoon.com/project/php/login_user.php";
final TextEditingController _emcontroller = TextEditingController();
String _email = "";
final TextEditingController _passcontroller = TextEditingController();
String _password = "";
bool _isChecked = false;

final User user = new User();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    loadpref();
    print('Init: $_email');
    super.initState();
    loadData();
  }

  List<DropdownMenuItem<String>> listCategory = [];
  List<String> category = ["SOC Staff", "SOC Management", "Responsible Person"];
  String currentCategory = 'SOC Staff';

  void loadData() {
    listCategory = [];
    listCategory = category
        .map((val) => new DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.deepOrangeAccent));
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                scale: 3.5,
              ),
              TextField(
                  controller: _emcontroller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', icon: Icon(Icons.email))),
              TextField(
                controller: _passcontroller,
                decoration: InputDecoration(
                    labelText: 'Password', icon: Icon(Icons.lock)),
                obscureText: true,
              ),
              SizedBox(
                height: 10,
              ),
              FormField(builder: (FormFieldState state) {
                var dropdownButton = new DropdownButton<String>(
                  items: category.map((String val) {
                    return new DropdownMenuItem<String>(
                      value: val,
                      child: new Text(val),
                    );
                  }).toList(),
                  hint: Text('Category'),
                  iconSize: 40.0,
                  elevation: 16,
                  onChanged: (String categorySave) {
                    setState(() {
                      user.category = categorySave;
                      currentCategory = categorySave;
                      print(currentCategory);
                    });
                  },
                  value: currentCategory,
                );
                return InputDecorator(
                    decoration: InputDecoration(
                        labelText: 'Please choose your category: '),
                    child: new DropdownButtonHideUnderline(
                      child: dropdownButton,
                    ));
              }),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                minWidth: 300,
                height: 50,
                child: Text('Login'),
                color: Colors.deepOrange,
                textColor: Colors.white,
                elevation: 15,
                onPressed: _onLogin,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool value) {
                      _onChange(value);
                    },
                  ),
                  Text('Remember Me', style: TextStyle(fontSize: 16))
                ],
              ),
              GestureDetector(
                  onTap: _onRegister,
                  child: Text('Register New Account',
                      style: TextStyle(fontSize: 16))),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                  onTap: _onForgot,
                  child:
                      Text('Forgot Account', style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }

  void _onLogin() {
    /*_email = _emcontroller.text;
    _password = _passcontroller.text;
    if (_isEmailValid(_email) && (_password.length > 4)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Login in");
      pr.show();
      http.post(urlLogin, body: {
        "email": _email,
        "password": _password,
      }).then((res) {
        print(res.statusCode);
        var string = res.body;
        List dres = string.split(",");
        print(dres);
        Toast.show(dres[0], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        if (dres[0] == "success") {
          pr.dismiss();
          //print("Radius:");
          print(dres);
          User user = new User(
              name: dres[1],
              email: dres[2],
              phone: dres[3],
              position: dres[4],
              category: dres[5]);*/
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MainScreen(user: user)));
    /*} else {
          pr.dismiss();
        }
      }).catchError((err) {
        pr.dismiss();
        print(err);
      });
    } else {}*/
  }

  void _onRegister() {
    print('onRegister');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  void _onForgot() {
    print('Forgot');
  }

  void _onChange(bool value) {
    setState(() {
      _isChecked = value;
      savepref(value);
    });
  }

  void loadpref() async {
    print('Inside loadpref()');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = (prefs.getString('email'));
    _password = (prefs.getString('pass'));
    print(_email);
    print(_password);
    if (_email.length > 1) {
      _emcontroller.text = _email;
      _passcontroller.text = _password;
      setState(() {
        _isChecked = true;
      });
    } else {
      print('No pref');
      setState(() {
        _isChecked = false;
      });
    }
  }

  void savepref(bool value) async {
    print('Inside savepref');
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //true save pref( Store value in pref)
      if (_isEmailValid(_email) && (_password.length > 5)) {
        await prefs.setString('email', _email);
        await prefs.setString('pass', _password);
        print('Pref Stored');
        print('Save pref $_email');
        print('Save pref $_password');
        Toast.show("Preferences have been saved", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        //Remove value from pref
        print('No email');
        setState(() {
          _isChecked = false;
        });
        Toast.show("Check your credentials", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } else {
      await prefs.setString('email', '');
      await prefs.setString('pass', '');
      setState(() {
        _emcontroller.text = '';
        _passcontroller.text = '';
        _isChecked = false;
      });
      print('Remove pref');
      Toast.show("Preferences have been removed", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}
