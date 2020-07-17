import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/screens/cart_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/widgets/numeric_pad.dart';
import 'package:shoptempdb/models/http_exception.dart';



class VerifyPhone extends StatefulWidget {

  final String phoneNumber;

  VerifyPhone({@required this.phoneNumber});

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  String code = "";
  var _isLoading = false;

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
//    if (!_formKey.currentState.validate()) {
//      // Invalid!
//      return;
//    }
//    _formKey.currentState.save();
//    setState(() {
//      _isLoading = true;
//    });
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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

                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                            buildCodeNumberBox(code.length > 0 ? code.substring(0, 1) : ""),
                            buildCodeNumberBox(code.length > 1 ? code.substring(1, 2) : ""),
                            buildCodeNumberBox(code.length > 2 ? code.substring(2, 3) : ""),
                            buildCodeNumberBox(code.length > 3 ? code.substring(3, 4) : ""),
                            buildCodeNumberBox(code.length > 4 ? code.substring(4, 5) : ""),
                            buildCodeNumberBox(code.length > 5 ? code.substring(5, 6) : ""),

                          ],
                        ),
                      ),
                      auth.otp != null
                          ? Text(auth.otp,style: TextStyle(fontSize: 10),)
                          : SizedBox(
                        height: 0.0,
                      ),

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
                              onTap: () {
                                print("Resend the code to the user");
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
                            _submit(cart,auth.otp);
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

              NumericPad(
                onNumberSelected: (value) {
                  print(value);
                  setState(() {
                    if(value != -1){
                      if(code.length < 6){
                        code = code + value.toString();
                      }
                    }
                    else{
                      code = code.substring(0, code.length - 1);
                    }
                    print(code);
                  });
                },
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
        width: 50,
        height: 50,
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