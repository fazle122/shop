


import 'dart:math';
import 'package:shoptempdb/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/screens/cart_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/screens/verifty_user.dart';

import '../base_state.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery
        .of(context)
        .size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends BaseState<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _authData = {
    'mobile_no': '',
    'otp': '',
  };
  var _isLoading = false;
  final _phoneController = TextEditingController();



  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) =>
            AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('ok'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ));
  }

  Future<void> _submit(Auth auth,Cart cart) async {

    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
        await Provider.of<Auth>(context, listen: false).signUp(_authData['mobile_no']);
        if(auth.otp != null)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerifyPhone(phoneNumber: _phoneController.text,otp: auth.otp,)),
        );
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a use with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate you, please try again later';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final cart = Provider.of<Cart>(context);
    final deviceSize = MediaQuery
        .of(context)
        .size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 180,
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _phoneController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                  ),
                  keyboardType: TextInputType.number,
//                  validator: (value) {
//                    if (value.isEmpty || !value.contains('@')) {
//                      return 'Invalid email!';
//                    }
//                  },
                  onSaved: (value) {
                    _authData['mobile_no'] = value;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                _isLoading?
                  CircularProgressIndicator():
                  RaisedButton(
                    child:
                    Text('GET OTP'),
                    onPressed: () async{
                      await _submit(auth,cart);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                    EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme
                        .of(context)
                        .primaryColor,
                    textColor: Theme
                        .of(context)
                        .primaryTextTheme
                        .button
                        .color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
