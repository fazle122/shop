import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/models/http_exception.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';
import 'package:shoptempdb/screens/create_profile_screen.dart';
import 'package:toast/toast.dart';


class LoginScreen extends StatefulWidget{
  static const routeName = 'log-in';
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen>{
  final GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  bool _getOTP = false;
  String mobileNo;
  var otp = null;

  int _counter = 0;
  Timer _timer;

  var _isInit = true;
  var _isLoading = false;

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     if (!mounted) return;
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<ShippingAddress>(context).fetchShippingAddressList().then((_) {
  //       if (!mounted) return;
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  _fetchShippingAddressList() async{
    final shippingData = Provider.of<ShippingAddress>(context,listen: false);

    if (_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      await Provider.of<ShippingAddress>(context,listen: false).fetchShippingAddressList().then((_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        if (shippingData.allShippingAddress.length > 0) {
          Navigator.of(context).pushReplacementNamed(
              DeliveryAddressScreen.routeName);
        } else {
          Navigator.of(context).pushReplacementNamed(
              CreateProfileScreen.routeName,
              arguments: _phoneController.text);
        }
      });
    }
    _isInit = false;
  }



  Widget phoneField() {
    return Container(
      padding: EdgeInsets.only(left: 50.0,right: 50.0),
      height: MediaQuery.of(context).size.height * 1/15,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: _phoneController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.phone_android,
            color: Theme.of(context).primaryColorDark,
          ),
          hintText: 'mobile number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  Widget otpField() {
    return Container(
      padding: EdgeInsets.only(left: 120.0,right: 120.0),
      height: MediaQuery.of(context).size.height * 1/15,

      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: _otpController,
        decoration: InputDecoration(
          hintText: 'eg: 543210',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
        ),
      ),
    );
  }

  Future<void> _getOTPCode() async {
    try {
        await Provider.of<Auth>(context, listen: false).signUp(_phoneController.text);
      // setState(() {
      //   _phoneController.text = null;
      // });


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
  }

  Future<void> _login() async {
    try {
      if(_otpController.text == null || _otpController.text == '' || _otpController.text == "" || _otpController.text.isEmpty){
        Toast.show('Please provide OTP code', context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      }else{
        await Provider.of<Auth>(context, listen: false).login(_phoneController.text, _otpController.text);
        Future.delayed(const Duration(milliseconds: 500), ()  async{
          await _fetchShippingAddressList();
        });
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
    // setState(() {
    //   _isLoading = false;
    // });
  }

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

  void _startTimer() {
    _counter = 10;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final cart = Provider.of<Cart>(context,listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Mobile Login'),),
      body:SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 30,),

            Text(!_getOTP?'Enter your mobile number':'Mobile Login',
              style: TextStyle(color:Colors.red,fontWeight: FontWeight.bold,fontSize: 22.0),),
            SizedBox(height: 10,),

            Center(child:Text(!_getOTP?'You will receive an OTP via SMS':'To complete the login process, please \n enter the 6 digit code below',
              style: TextStyle(color:Colors.grey,fontWeight: FontWeight.bold,fontSize: 15.0),),),
            SizedBox(height: 20,),

            _getOTP?otpField():phoneField(),
            SizedBox(height: 5,),

            Consumer<Auth>(builder: (context,authData,child) =>
            authData.otp!= null?Text(authData.otp):SizedBox(width: 0.0,height: 0.0,),),
            SizedBox(height: 20,),

            !_getOTP? SizedBox(width: 0.0,height: 0.0,):GestureDetector(
              child: Container(
                width: _counter > 0 ? MediaQuery.of(context).size.width *1/2:MediaQuery.of(context).size.width *1/4,
                height: MediaQuery.of(context).size.height *1/25,
                decoration: BoxDecoration(
                  color: _counter > 0 ? Colors.grey:Colors.red,
                  borderRadius: BorderRadius.all(
                    Radius.circular(2),
                  ),
                ),
                child: Center(
                  child: Text(
                    _counter > 0 ? "Resend code in $_counter seconds":
                    'Resend code',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: _counter > 0?FontWeight.normal:FontWeight.bold,
                        color: _counter > 0?Colors.black:Colors.white
                    ),
                  ),
                ),
              ),
              onTap: _counter > 0? null :() {
                _startTimer();
                _getOTPCode();
              },
            ),
            SizedBox(height: 30,),
            GestureDetector(
                onTap: () {
                  if(_phoneController.text == null || _phoneController.text == '' || _phoneController.text == "" || _phoneController.text.isEmpty){
                    Toast.show('Please provide a valid mobile number', context,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
                  }else{
                    _startTimer();
                    setState(() {
                      _getOTP = true;
                    });
                    auth.otp != null? _login():_getOTPCode();
                  }

                },
                child: Container(
                  width: MediaQuery.of(context).size.width *1/2,
                  height: MediaQuery.of(context).size.height *1/15,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      !_getOTP ?"Get OTP":"Login with OTP",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      )
    );
  }

}