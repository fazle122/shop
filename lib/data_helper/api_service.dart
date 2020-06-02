import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {

  static final String BASE_URL = "http://new.bepari.net/demo/"; //dev
  static final String CDN_URl = "http://devcdn.baniadam.info/"; //dev
  static final Dio dioService = new Dio();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    String qString = ApiService.BASE_URL + "api/V1/access-control/login";
    var responseData;

    final Map<String, dynamic> authData = {
      'client_id': 3,
      'client_secret': 'zKu8puNCPZYTYYBRsHtw3Efz8hemktaP1LZ73aSf',
      'email': email,
      'password': password,
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
      responseData = json.decode(response.body);
    } catch (Exception) {
      return null;
    }

    if (responseData['code'] == 200) {
      return responseData;
    }
    return responseData;
  }

  static Future<Map<String, dynamic>> logout(String cID,String instanceId) async {
    String qString = ApiService.BASE_URL + "$cID/api/in/v1/logout";
    var responseData;

    final Map<String, dynamic> authData = {
      'grant_type': 'password',
      'client_id': 3,
      'client_secret': 'W5nQYuW1OFknDwiFnU96Y7dBMqTJ5jG6r6AXYk9q',
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
      responseData = json.decode(response.body);
    } catch (Exception) {
      return null;
    }

    if (responseData['code'] == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return responseData;
    }
    return responseData;
  }

  static Future<Map<String,dynamic>> getProductList() async {

    String qString = BASE_URL + "api/V1/product-catalog/product/list-product";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final http.Response response = await http.get(
      qString,
      headers: headers,
    );

    final Map<String,dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseData;
    }
    return responseData;
  }


}
