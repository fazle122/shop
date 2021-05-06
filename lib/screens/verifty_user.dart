import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/screens/cart_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shoptempdb/utility/http_exception.dart';

class VerifyPhone extends StatefulWidget {

  final String phoneNumber;
  final String otp;

  VerifyPhone({@required this.phoneNumber,@required this.otp});

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final GlobalKey<FormState> formKey = GlobalKey();
  String code = "";
  var _isLoading = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType> errorController;
  String currentText = "";
  bool hasError = false;


  @override
  void initState() {
    super.initState();
    code = widget.otp;
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

  Future<void> _submit(Cart cart, var otp) async {
    if (!formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
        await Provider.of<Auth>(context, listen: false).login(widget.phoneNumber, otp);

        cart.items.length <= 0 ?
        Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName)
            :Navigator.of(context).pushReplacementNamed(CartScreen.routeName);

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

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            size: 30,
            color: Colors.black,
          ),
        ),
        title: Text(
          "Verify user",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        textTheme: Theme.of(context).textTheme,
      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          "Code is sent to " + widget.phoneNumber,
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFF818181),
                          ),
                        ),
                      ),

                      Form(
                        key: formKey,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 30),
                            child: PinCodeTextField(
                              autoFocus: true,
                              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                              length: 6,
                              obsecureText: false,
                              animationType: AnimationType.fade,
                              validator: (v) {
                                if (v.length <5) {
                                  return '*error';
                                } else {
                                  return null;
                                }
                              },
                              pinTheme: PinTheme(
                                inactiveFillColor: Colors.white,
                                activeColor: Theme.of(context).primaryColor,
                                selectedFillColor: Colors.grey[100],
                                selectedColor: Theme.of(context).primaryColor,
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor:
                                hasError ? Colors.orange : Colors.white,
                              ),
                              animationDuration: Duration(milliseconds: 300),
//                              backgroundColor: Colors.blue.shade50,
                              enableActiveFill: true,
                              errorAnimationController: errorController,
                              controller: textEditingController,
                              onCompleted: (v) {
                                print("Completed");
                              },
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  currentText = value;
                                  print(currentText);
                                });
                              },
                              beforeTextPaste: (text) {
                                print("Allowing to paste $text");
                                return false;
                              },
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          hasError ? "*Please fill up all the cells properly" : "",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ),

                      // auth.otp != null
                      //     ? Text(auth.otp,style: TextStyle(fontSize: 10),)
                      //     : SizedBox(
                      //   height: 0.0,
                      // ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[


                            Text(
                              "Didn't recieve code? ",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF818181),
                              ),
                            ),

                            SizedBox(
                              width: 8,
                            ),

                            GestureDetector(
                              onTap: () async{
                                try {
                                  await Provider.of<Auth>(context, listen: false).signUp(widget.phoneNumber);
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
                              },
                              child: Text(
                                "Request again",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: MediaQuery.of(context).size.height * 0.13,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            formKey.currentState.validate();
                            if (currentText.length != 6) {
                              setState(() {
                                hasError = true;
                              });
                            } else {_submit(cart,currentText);}

                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Verify and Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget buildCodeNumberBox(String codeNumber) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 45,
        height: 45,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6F5FA),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 25.0,
                  spreadRadius: 1,
                  offset: Offset(0.0, 0.75)
              )
            ],
          ),
          child: Center(
            child: Text(
              codeNumber,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}