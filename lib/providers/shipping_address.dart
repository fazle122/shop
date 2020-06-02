import 'package:flutter/foundation.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shoptempdb/models/http_exception.dart';




class AddressItem{
  final String id;
  final String areaId;
  final String shippingAddress;
  final String customerId;

  AddressItem({
    @required this.id,
    @required this.areaId,
    @required this.shippingAddress,
    @required this.customerId,
  });

}

class ShippingAddress with ChangeNotifier{
  AddressItem _addressItem;
  final String authToken;
  final String userId;

  ShippingAddress(this.authToken,this.userId,this._addressItem);

  Map<int,dynamic> _areaList = Map();


  AddressItem get getShippingAddress{
    return _addressItem;
  }

  Map<int,dynamic> get getAreaList{
    return _areaList;
  }

  Future<void> fetchAreaList() async {
    var url = 'http://new.bepari.net/demo/api/V1/crm/customer/list-shipping-address';
    Map<int, dynamic> areaData = Map();
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      for(int i =0; i<data['data']['area'].length; i++){
        areaData[data['data']['area'][i]['id']] = data['data']['area'][i]['area'];
      }
      _areaList = areaData;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> createShippingAddress(int areaId, String address) async {
    var responseData;
    String qString = "http://new.bepari.net/demo/api/V1/crm/customer/create-shipping-address";
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> authData = {
      'area_id': areaId.toString(),
      'shipping_address_line': address,
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
        headers: headers,
      );
      responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}