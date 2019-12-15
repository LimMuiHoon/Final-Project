import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:final_project/loginscreen.dart';
import 'package:final_project/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

String pathAsset = 'assets/images/logo.png';
String urlUpload = "https://limmuihoon.com/project/php/register_user.php";
File _image;
final TextEditingController _namecontroller = TextEditingController();
final TextEditingController _emcontroller = TextEditingController();
final TextEditingController _passcontroller = TextEditingController();
final TextEditingController _phcontroller = TextEditingController();
final TextEditingController _pocontroller = TextEditingController();
//final TextEditingController _catSelectedcontroller = TextEditingController();

//var _cat = ['SOC Staff', 'SOC Management', 'Responsible Person'];
String _name, _email, _password, _phone, _position;
//bool _isChecked = false;
//_category;
//_catSelected = 'SOC Staff';

final User user = new User();

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
  const RegisterScreen({Key key, File image}) : super(key: key);
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.deepOrange));
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('New User Registration'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: RegisterWidget(),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    _image = null;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
    return Future.value(false);
  }
}

class RegisterWidget extends StatefulWidget {
  @override
  RegisterWidgetState createState() => RegisterWidgetState();
}

class RegisterWidgetState extends State<RegisterWidget> {
  //String _catSelected;

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
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
            onTap: _choose,
            child: Container(
              width: 180,
              height: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _image == null
                        ? AssetImage(pathAsset)
                        : FileImage(_image),
                    fit: BoxFit.fill,
                  )),
            )),
        Text('Click on image above to take profile picture'),
        TextField(
            controller: _emcontroller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              icon: Icon(Icons.email),
            )),
        TextField(
            controller: _namecontroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Name',
              icon: Icon(Icons.person),
            )),
        TextField(
          controller: _passcontroller,
          decoration:
              InputDecoration(labelText: 'Password', icon: Icon(Icons.lock)),
          obscureText: true,
        ),
        TextField(
            controller: _phcontroller,
            keyboardType: TextInputType.phone,
            decoration:
                InputDecoration(labelText: 'Phone', icon: Icon(Icons.phone))),
        SizedBox(
          height: 10,
        ),
        TextField(
            controller: _pocontroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Position',
              icon: Icon(Icons.person),
            )),
        /*TextField(
          controller: _pocontroller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              labelText: 'Position', icon: Icon(Icons.people_outline)),
          //obscureText: true,
        ),*/

        /* DropdownButton<String>(
          items: _cat.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String newValueSelected) {
            setState(() {
              this._catSelected = newValueSelected;
            });
          },
          value: _catSelected,
        ), */
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
              decoration:
                  InputDecoration(labelText: 'Please choose your category: '),
              child: new DropdownButtonHideUnderline(
                child: dropdownButton,
              ));
        }),
        SizedBox(
          height: 20,
        ),
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          minWidth: 300,
          height: 50,
          child: Text('Register'),
          color: Color.fromRGBO(159, 30, 99, 1),
          textColor: Colors.white,
          elevation: 15,
          onPressed: _onRegister,
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
            onTap: _onBackPress,
            child: Text('Already Register', style: TextStyle(fontSize: 16))),
      ],
    );
  }

  void _choose() async {
    _image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {});
    //_image = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  void _onRegister() {
    print('onRegister Button from RegisterUser()');
    print(_image.toString());
    uploadData();
  }

  void _onBackPress() {
    _image = null;
    print('onBackpress from RegisterUser');
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  void uploadData() {
    _name = _namecontroller.text;
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    _phone = _phcontroller.text;
    _position = _pocontroller.text;
    currentCategory = user.category;

    if ((_isEmailValid(_email)) &&
        (_password.length > 5) &&
        (_image != null) &&
        (_phone.length > 5)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Registration in progress");
      pr.show();

      String base64Image = base64Encode(_image.readAsBytesSync());
      http.post(urlUpload, body: {
        "encoded_string": base64Image,
        "name": _name,
        "email": _email,
        "password": _password,
        "phone": _phone,
        "position": _position,
        "category": currentCategory,
      }).then((res) {
        print(res.statusCode);
        if (res.body == "success") {
          Toast.show(res.body, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          _image = null;
          _namecontroller.text = '';
          _emcontroller.text = '';
          _phcontroller.text = '';
          _passcontroller.text = '';
          _pocontroller.text = '';
          pr.dismiss();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage()));
        }
      }).catchError((err) {
        print(err);
      });
    } else {
      Toast.show("Check your registration information", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void savepref(String email, String pass) async {
    print('Inside savepref');
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //true save pref
    await prefs.setString('email', email);
    await prefs.setString('pass', pass);
    print('Save pref $_email');
    print('Save pref $_password');
  }
}
