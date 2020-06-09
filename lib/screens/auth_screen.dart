import 'dart:math';
import 'package:shoptempdb/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';

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

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Signup;
  Map<String, String> _authData = {
    'mobile_no': '',
    'otp': '',
  };
  var _isLoading = false;
  final _otpController = TextEditingController();

//  @override
//  void initState() {
//    super.initState();
//    Provider.of<Auth>(context);
//  }
  void _showErrorDialog(String message) {
    showDialog(
        context: context,
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

  Future<void> _submit(AuthMode mode) async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (mode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['mobile_no'], _authData['otp']);
        Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData['mobile_no']);
      }
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

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final deviceSize = MediaQuery
        .of(context)
        .size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 200 : 250,
//        constraints: BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 150 : 200),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Phone number',
//                    labelText: 'Phone number',
                  ),
                  keyboardType: TextInputType.emailAddress,
//                  validator: (value) {
//                    if (value.isEmpty || !value.contains('@')) {
//                      return 'Invalid email!';
//                    }
//                  },
                  onSaved: (value) {
                    _authData['mobile_no'] = value;
                  },
                ),
                auth.otp != null
                    ? TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'otp',
//                    labelText: 'otp',
                  ),
                  obscureText: true,
                  controller: _otpController,
//                  validator: (value) {
//                    if (value.isEmpty || value.length < 5) {
//                      return 'Password is too short!';
//                    }
//                  },
                  onSaved: (value) {
                    _authData['otp'] = value;
                  },
                )
                    : SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
                SizedBox(
                  height: 10,
                ),
//                _authMode == AuthMode.Login? Text('otp'):SizedBox(height: 0.0,),
                auth.otp != null
                    ? Text(auth.otp)
                    : SizedBox(
                  height: 0.0,
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
//                    Text(_authMode == AuthMode.Login ? 'LOGIN' : 'GET OTP'),
                    Text(auth.otp != null ? 'LOGIN' : 'GET OTP'),
                    onPressed: () {
                      _switchAuthMode();
                      FocusScope.of(context).requestFocus(new FocusNode());
                      auth.otp != null
                          ? _submit(AuthMode.Login)
                          : _submit(AuthMode.Signup);
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

//                FlatButton(
//                  child: Text(
//                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'}'),
//                  onPressed: _switchAuthMode,
//                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
//                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                  textColor: Theme.of(context).primaryColor,
//                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
