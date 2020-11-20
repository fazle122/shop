import 'package:flutter/foundation.dart';
import 'package:shoptempdb/utility/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shoptempdb/models/http_exception.dart';



class OrderItem{
  final int id;
  final double invoiceAmount;
  final double totalDue;
  final List<InvoiceItem> invoiceItem;
  final DateTime invoiceDate;
  final DateTime delivaryDate;
  final int status;

  OrderItem({
   @required this.id,
   @required this.invoiceAmount,
    @required this.totalDue,
    @required this.invoiceItem,
    @required this.invoiceDate,
    @required this.delivaryDate,
    @required this.status,
});

}

class InvoiceItem{
  final int id;
  final int productID;
  final double quantity;
  final double unitPrice;
  final String productName;

  InvoiceItem({
    @required this.id,
    @required this.productID,
    @required this.quantity,
    @required this.unitPrice,
    @required this.productName,
  });

}

//class Orders with ChangeNotifier {
//  List<OrderItem> _orders = [];
//  final String authToken;
//  final String userid;
//
//  Orders(this.authToken,this.userid,this._orders);
//
//  List<OrderItem> get orders {
//    return [..._orders];
//  }
//
//  Future<void> fetchAndSetOrders() async {
//    final url = 'http://new.bepari.net/demo/api/V1.0/accounts/invoice/list-invoice';
//    Map<String, String> headers = {
//      'Authorization': 'Bearer ' + authToken,
//      'Content-Type': 'application/json',
//    };
//    final http.Response response = await http.get(
//      url,
//      headers: headers,
//    );
//    final List<OrderItem> loadedOrders = [];
//    final extarctedData = json.decode(response.body) as Map<String, dynamic>;
//    if(extarctedData == null){
//      return;
//    }
//
//    var allOrders = extarctedData['data']['invoices']['data'];
//    for(int i=0; i<allOrders.length; i++){
//      final OrderItem orders = OrderItem(
//        id: allOrders[i]['id'],
//        invoiceAmount: double.parse(allOrders[i]['invoice_amount']),
//        totalDue: double.parse(allOrders[i]['total_due']),
//        dateTime: DateTime.parse(allOrders[i]['invoice_date']),
//      );
//      loadedOrders.add(orders);
//    }
//    _orders = loadedOrders.reversed.toList();
//    notifyListeners();
//  }
//
////  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
////    final url = 'https://flutter-projects-1234.firebaseio.com/orders/$userid.json?auth=$authToken';
////    final timeStamp = DateTime.now();
////    final response = await http.post(url,
////        body: json.encode({
////          'amount': total,
////          'dateTime': timeStamp.toIso8601String(),
////          'products': cartProducts
////              .map((cp) => {
////            'id': cp.id,
////            'title': cp.title,
////            'quantity': cp.quantity,
////            'price': cp.price,
////          })
////              .toList(),
////        }));
////    _orders.insert(
////        0,
////        OrderItem(
////            id: json.decode(response.body)['name'],
////            amount: total,
////            products: cartProducts,
////            dateTime: timeStamp));
////    notifyListeners();
////  }
//}

class Orders with ChangeNotifier{
  List<OrderItem> _orders = [];
  final String authToken;
  final String userid;
  int lastPageCount;


  Orders(this.authToken,this.userid,this._orders);

  OrderItem _orderItem;

  OrderItem get singOrderItem{
    return _orderItem;
  }

  List<OrderItem> get orders{
    return [..._orders];
  }

  List _deliveryChargeData =[];

  List get delChargeData {
    return [..._deliveryChargeData];
  }


  int get lastPageNo {
    return lastPageCount;
  }


  Future<Map<String,dynamic>> addOrder(FormData formData) async{

    Dio dioService = new Dio();
    final url = ApiService.BASE_URL +  'api/V1.0/accounts/invoice/create-invoice';

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    try {
      final Response response = await dioService.post(
        url,
        data: formData,
      );

      final responseData = response.data;
      print(responseData);
      notifyListeners();
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    }catch(error){
      // throw error;
      return null;
    }
  }

  Future<Map<String, dynamic>> cancelOrder(String orderId,String reason) async{

    var responseData;
    final url = ApiService.BASE_URL +  'api/V1.0/accounts/invoice/cancel-my-invoice/$orderId';

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> data = {
      'cancel_msg': reason,
    };
    try {
      final http.Response response = await http.post(
        url,
        body: json.encode(data),
        headers: headers,
      );
      responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      }
      return null;

    }catch(error){
      return null;
      // throw error;
    }
  }

  Future<List<OrderItem>> fetchAndSetOrders(Map<String,dynamic> filters,int pageCount) async {

    String url = 'http://new.bepari.net/demo/api/V1.0/accounts/invoice/list-my-invoice?page_size=10&page=$pageCount';

    if (filters != null) {

      if (filters.containsKey('invoice_from_date') && filters['invoice_from_date'] != null) {
        url += '&inv_from_date=' + filters['invoice_from_date'].toString();
      }
      if (filters.containsKey('invoice_to_date') && filters['invoice_to_date'] != null) {
        url += '&inv_to_date=' + filters['invoice_to_date'].toString();
      }
//      if (currentPage != null) {
//        qString += '&page=$currentPage';
//      }
    }
    Dio dioService = new Dio();
    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final Response response = await dioService.get(url,);
      final List<OrderItem> loadedOrders = [];
//      final extractedData = json.decode(response.data) as Map<String, dynamic>;
      final extractedData = response.data;
      if (extractedData == null) {
        return null;
      }

      if(extractedData['data'].length > 0){
      var allOrders = extractedData['data']['data'];
      for (int i = 0; i < allOrders.length; i++) {
        final OrderItem orders = OrderItem(
          id: allOrders[i]['id'],
          invoiceAmount: double.parse(allOrders[i]['invoice_amount']),
          totalDue: double.parse(allOrders[i]['total_due']),
          invoiceDate: DateTime.parse(allOrders[i]['invoice_date']),
          delivaryDate: DateTime.parse(allOrders[i]['delivery_date']),
          status: allOrders[i]['status'],

        );
        loadedOrders.add(orders);
      }
      lastPageCount = extractedData['data']['last_page'];
      _orders = loadedOrders;
      }else{
        _orders = [];
      }
      notifyListeners();
      return _orders;

    }
    catch (error) {
      return null;
      // throw (error);
    }
  }

  Future<void> fetchSingleOrder(int orderId) async {
    final url = 'http://new.bepari.net/demo/api/V1.0/accounts/invoice/view-my-invoice/$orderId';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final http.Response response = await http.get(
      url,
      headers: headers,
    );
    final extarctedData = json.decode(response.body) as Map<String, dynamic>;
    if(extarctedData == null){
      return;
    }

    var allOrders = extarctedData['data'];
      final OrderItem orderItem = OrderItem(
        id: allOrders['id'],
        totalDue: double.parse(allOrders['total_due']),
        invoiceDate: DateTime.parse(allOrders['invoice_date']),
        delivaryDate: DateTime.parse(allOrders['delivery_date']),
//        invoiceAmount: allOrders['invoice_amount'].toDouble(),
        invoiceAmount: double.parse(allOrders['invoice_amount']),
        invoiceItem: (allOrders['invoice_details'] as List<dynamic>).map((item) => InvoiceItem(
          id: item['id'],
          productID: item['product_id'],
//            unitPrice: item['unit_price'].toDouble(),
            unitPrice: double.parse(item['unit_price']),
          quantity: double.parse(item['quantity']),
          productName: item['product_name']
        )).toList(),

//          for(int i = 0; i<allOrders['invoice_details'].length; i++){}
      );
    _orderItem = orderItem;
    notifyListeners();
  }

  Future<void> fetchCompletedOrders() async {
    print('fetch orders');
    final url = 'http://new.bepari.net/demo/api/V1.0/accounts/invoice/list-invoice';


    Dio dioService = new Dio();
    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final Response response = await dioService.get(url,);
      final List<OrderItem> loadedOrders = [];
//      final extractedData = json.decode(response.data) as Map<String, dynamic>;
      final extractedData = response.data;
      if (extractedData == null) {
        return;
      }

      if(extractedData['data']['invoices'].length > 0){
        var allOrders = extractedData['data']['invoices']['data'];
        for (int i = 0; i < allOrders.length; i++) {
          final OrderItem orders = OrderItem(
            id: allOrders[i]['id'],
            invoiceAmount: allOrders[i]['invoice_amount'].toDouble(),
            totalDue: allOrders[i]['total_due'].toDouble(),
            invoiceDate: DateTime.parse(allOrders[i]['invoice_date']),
          );
          loadedOrders.add(orders);
        }
        _orders = loadedOrders;
      }else{
        _orders = [];
      }
      notifyListeners();
    }
    catch (error) {
      throw (error);
    }
  }
}