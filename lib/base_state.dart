import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:access_settings_menu/access_settings_menu.dart';



abstract class BaseState<T extends StatefulWidget> extends State<T> {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool isOnline = true;

  Future<void> initConnectivity() async {
    try {
      await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return;
    }

    await updateConnectionStatus().then((bool isConnected) =>
        setState(() {
          isOnline = isConnected;
        }));
  }


  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      await updateConnectionStatus().then((bool isConnected) =>
          setState(() {
            isOnline = isConnected;
            print('Connected: ' + isOnline.toString());
            if (!isOnline) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => _connectionDialog(context),
              );
            }
          }
          ));
    });
  }


  _connectionDialog(context) {
    return AlertDialog(
      title: Center(
        child: Text('Internet interruption'),
      ),
      content: Text('No internet. Please check your internet connection.'),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Network setting'),
          onPressed: () {
            openSettingsMenu('ACTION_WIFI_SETTINGS');
            Navigator.pop(context, true);
          },
        )
      ],
    );
  }

  openSettingsMenu(settingsName) async {
    var resultSettingsOpening = false;

    try {
      resultSettingsOpening =
      await AccessSettingsMenu.openSettings(settingsType: settingsName);
    } catch (e) {
      resultSettingsOpening = false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    _connectivitySubscription.pause();
    super.deactivate();
  }


  Future<bool> updateConnectionStatus() async {
    bool isConnected;
    try {
      final List<InternetAddress> result =
      await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
      return false;
    }
    return isConnected;
  }
}