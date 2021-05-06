import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shoptempdb/utility/api_service.dart';
import 'package:shoptempdb/utility/http_exception.dart';



class AddressItem{
  final String id;
  final String city;
  final String areaId;
  final String shippingAddress;
  final String customerId;
  final String phoneNumber;

  AddressItem({
    @required this.id,
    @required this.city,
    @required this.areaId,
    @required this.shippingAddress,
    @required this.customerId,
    @required this.phoneNumber,
  });
}

class ProfileItem{
  final String id;
  final String name;
  final String displayName;
  final String gender;
  final String email;
  final String mobileNumber;
  final String address;
  final String city;
  final String areaId;
  final String contactPerson;
  final String contactPersonMobileNumber;

  ProfileItem({
    @required this.id,
    @required this.name,
    @required this.displayName,
    @required this.gender,
    @required this.email,
    @required this.mobileNumber,
    @required this.address,
    @required this.city,
    @required this.areaId,
    @required this.contactPerson,
    @required this.contactPersonMobileNumber,
  });
}

class ShippingDateItem{
  final String date;
  final List<ShippingTimeItem> time;

  ShippingDateItem({
    @required this.date,
    @required this.time,
  });
}

class ShippingTimeItem {
  final String startTime;
  final String endTime;

  ShippingTimeItem({
    @required this.startTime,
    @required this.endTime,
  });
}

class ShippingAddress with ChangeNotifier{
  List<AddressItem> _allShippingAddress = [];
  List<ShippingDateItem> _allShippingDates = [];
  List<ShippingTimeItem> _allShippingTimes = [];

  ShippingDateItem _selectedDate;
  ShippingTimeItem _selectedTime;

  AddressItem _addressItem;
  final String authToken;
  final String userId;

  ShippingAddress(this.authToken,this.userId,this._allShippingAddress);

  Map<String,dynamic> _districtList = Map();
  Map<String,dynamic> _areaList = Map();
  ProfileItem _profileItem;

  ProfileItem get profileInfo{
    return _profileItem;
  }

  List<AddressItem> get allShippingAddress{
    return [..._allShippingAddress];
  }

  List<ShippingDateItem> get allShippingDates{
    return [..._allShippingDates];
  }

  List<ShippingTimeItem> get allShippingTimes{
    return [..._allShippingTimes];
  }

  set allShippingTimes(value){
    this._allShippingTimes = value;
    this.notifyListeners();
  }

  AddressItem get getDeliveryAddress{
    return _addressItem;
  }

  Map<String,dynamic> get allDistricts{
    return _districtList;
  }

  Map<String,dynamic> get allAreas{
    return _areaList;
  }

  String _selectedDistrict;
  String _selectedArea;


  String get selectedDistrict {
    return this._selectedDistrict;
  }
  set selectedDistrict(final String item) {
    this._selectedDistrict = item;
    fetchAreaList(item);
    this.notifyListeners();
  }

  String get selectedArea {
    return this._selectedArea;
  }
  set selectedArea(final String item) {
    this._selectedArea = item;
    this.notifyListeners();
  }

  ProfileItem getProfileInfo(){
    return _profileItem;
  }


  ShippingDateItem get selectedDate{
    return this._selectedDate;
  }
  set selectedDate(final ShippingDateItem item) {
    this._selectedDate = item;
    // this._allShippingTimes = this._selectedDate.time;
    this.notifyListeners();
  }

  ShippingTimeItem get selectedTime {
    return this._selectedTime;
  }

  set selectedTime(final ShippingTimeItem item) {
    this._selectedTime = item;
    this.notifyListeners();
  }

  Future<void> fetchDistrictList() async {
    List<dynamic> dbData = await ApiService.getDistrictDataFromLocalDB();
    Map<String,dynamic> districtData = Map();
    List<dynamic> data = [];
    data = dbData.map((model){
      return{
        'district': model['district'],
      };
    }).toList();

    if (data == null) {
      return;
    }
    for(int i =0; i<data.length; i++){
      districtData[i.toString()] = data[i]['district'];
    }
    _districtList = districtData;
    notifyListeners();
  }

  Future<void> fetchAreaList(String district) async {
    List<dynamic> dbData = await ApiService.getAreaDataFromLocalDB(district);
    Map<String,dynamic> areaData = Map();
    List<dynamic> data = [];
    data = dbData.map((model){
      return{
        'id':model['id'],
        'location':model['location'],
      };
    }).toList();

    if (data == null) {
      return;
    }
    for(int i =0; i<data.length; i++){
      areaData[data[i]['id']] = data[i]['location'];
    }
    _areaList = areaData;
    notifyListeners();
  }

  Future<String> fetchAreaName(String areaId) async {
    var area = await ApiService.getAreaNameFromLocalDB(areaId);
    print(area.toString());
    return area.toString();
  }


  Future<Map<String,dynamic>> createShippingAddress(String areaId, String city,String address,String phone) async {
    var responseData;
    String qString = ApiService.BASE_URL + "api/V1.0/crm/customer/create-shipping-address";

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> authData = {
      'area_id': areaId,
      'city' : city,
      'shipping_address_line': address,
      'mobile_no': phone,
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
        headers: headers,
      );
      responseData = json.decode(response.body);

      if(response.statusCode == 200) {
        return responseData;
      }else{
        return null;
      }
    } catch (error) {
      // throw error;
      return null;
    }
  }

  Future<Map<String,dynamic>> createShippingAddressWithOrder(String shippingAddressId,FormData data) async {
    String qString;
    Dio dioService = new Dio();
    if(shippingAddressId != null){
      qString = ApiService.BASE_URL + "api/V1.0/crm/customer/update-shipping-address/$shippingAddressId";

    }else {
      qString = ApiService.BASE_URL +  "api/V1.0/crm/customer/create-shipping-address";
    }

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    try {
      final Response response = await dioService.post(
        qString,
        data: data,
      );
      final responseData = response.data;

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      notifyListeners();
      if(response.statusCode == 200) {
        return response.data;
      }else{
        return null;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String,dynamic>> deleteShippingAddress(String shippingAddressId) async {
    Dio dioService = new Dio();
    String qString = ApiService.BASE_URL + "api/V1.0/crm/customer/delete-shipping-address/$shippingAddressId";

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    try {
      final Response response = await dioService.delete(qString);
      final responseData = response.data;

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      notifyListeners();
      if(response.statusCode == 200) {
        return response.data;
      }else{
        return null;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String,dynamic>> updateProfileInfo(String address,String phone,String name,String email,String district,int areaId) async {
    var responseData;
    String qString = ApiService.BASE_URL + "api/V1.0/access-control/user/update-profile";
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> authData = {
      'address': address,
      'mobile_no': phone,
      'name':name,
      'email':email,
      'city':district,
      'area_id':areaId
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
        headers: headers,
      );
      responseData = json.decode(response.body);



      notifyListeners();
      if (response.statusCode == 200) {
        return responseData;
      }
      return null;
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchProfileInfo() async {
    var url = ApiService.BASE_URL + 'api/V1.0/access-control/user/show-profile';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final http.Response response = await http.get(
        url,
        headers: headers,
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      var allData = data['data']['profile'];
        final ProfileItem info = ProfileItem(
          id: allData['id'].toString(),
          name: allData['name'],
          displayName: allData['display_name'],
          gender: allData['gender'],
          email: allData['email'],
          mobileNumber: allData['mobile'].toString(),
          address: allData['address'],
          city: allData['city'],
          areaId: allData['area_id'].toString(),
          contactPerson: allData['contact_person'],
          contactPersonMobileNumber: allData['contact_person_contact_no'],
        );
      _profileItem = info;
      notifyListeners();
    } catch (error) {throw (error);
    }
  }

  Future<void> fetchShippingAddressList() async {
    var url = ApiService.BASE_URL +  'api/V1.0/crm/customer/list-shipping-address';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final http.Response response = await http.get(
        url,
        headers: headers,
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      final List<AddressItem> loadedAddress = [];
      var alldata = data['data']['address'];
      for(int  i=0; i<alldata.length;i++){
        final AddressItem address = AddressItem(
          id: alldata[i]['id'].toString(),
          city:alldata[i]['city'],
          shippingAddress: alldata[i]['shipping_address_line'],
          areaId: alldata[i]['area_id'].toString(),
          customerId: alldata[i]['customer_id'].toString(),
          phoneNumber: alldata[i]['mobile_no'].toString(),
        );
        loadedAddress.add(address);
      }
      _allShippingAddress = loadedAddress.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchShippingDates() async {
    var url = ApiService.BASE_URL +  'api/V1.0/accounts/invoice/delivery-schedule';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final http.Response response = await http.get(
        url,
        headers: headers,
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      final List<ShippingDateItem> loadedDates = [];
      var allData = data['data'];
      for(int  i=0; i<allData.length;i++){
        final ShippingDateItem date = ShippingDateItem(
          date: allData[i]['date'].toString(),
          time:(data['data'][i]['time'] as List<dynamic>).map((item) => ShippingTimeItem(
            startTime: item['start_time'],
            endTime: item['end_time'],
        )).toList(),
        );
        loadedDates.add(date);
      }
      _allShippingDates = loadedDates;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchShippingAddress(String id) async {
    var url = ApiService.BASE_URL + 'api/V1.0/crm/customer/view-shipping-address/$id';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final http.Response response = await http.get(
        url,
        headers: headers,
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      var alldata = data['data'];
        final AddressItem address = AddressItem(
          id: alldata['id'].toString(),
          city:alldata['city'],
          shippingAddress: alldata['shipping_address_line'],
          areaId: alldata['area_id'].toString(),
          customerId: alldata['customer_id'].toString(),
          phoneNumber: alldata['mobile_no'].toString(),
        );

      _addressItem = address;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

}