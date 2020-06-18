import 'package:flutter/foundation.dart';
import 'package:shoptempdb/data_helper/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shoptempdb/models/http_exception.dart';



class OrderItem{
  final int id;
  final double invoiceAmount;
  final double totalDue;
  final List<InvoiceItem> invoiceItem;
  final DateTime dateTime;

  OrderItem({
   @required this.id,
   @required this.invoiceAmount,
    @required this.totalDue,
    @required this.invoiceItem,
   @required this.dateTime,
});

}

class InvoiceItem{
  final int id;
  final int productID;
  final int quantity;
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

  Orders(this.authToken,this.userid,this._orders);

  OrderItem _orderItem;

  OrderItem get singOrderItem{
    return _orderItem;
  }

  List<OrderItem> get orders{
    return [..._orders];
  }




  void addOrder(FormData formData) async{

    Dio dioService = new Dio();
    final url = ApiService.BASE_URL +  'api/V1.0/accounts/invoice/create-invoice';

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Response response = await dioService.post(
      url,
      data: formData,
    );

    final responseData = response.data;
    print(responseData);
    notifyListeners();
  }

  void cancelOrder(String orderId,String reason) async{

    var responseData;
    final url = ApiService.BASE_URL +  'api/V1.0/accounts/invoice/cancelled/$orderId';

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
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      notifyListeners();
    }catch(error){
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
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
          dateTime: DateTime.parse(allOrders[i]['invoice_date']),
        );
        loadedOrders.add(orders);
      }
      _orders = loadedOrders.reversed.toList();
      }else{
        _orders = [];
      }
      notifyListeners();
    }

//    Map<String, String> headers = {
//      'Authorization': 'Bearer ' + authToken,
//      'Content-Type': 'application/json',
//    };
//    try {
//      final http.Response response = await http.get(
//        url,
//        headers: headers,
//      );
//      final List<OrderItem> loadedOrders = [];
//      final extarctedData = json.decode(response.body) as Map<String, dynamic>;
//      if (extarctedData == null) {
//        return;
//      }
//
//      var allOrders = extarctedData['data']['invoices']['data'];
//      for (int i = 0; i < allOrders.length; i++) {
//        final OrderItem orders = OrderItem(
//          id: allOrders[i]['id'],
//          invoiceAmount: allOrders[i]['invoice_amount'].toDouble(),
//          totalDue: allOrders[i]['total_due'].toDouble(),
//          dateTime: DateTime.parse(allOrders[i]['invoice_date']),
//        );
//        loadedOrders.add(orders);
//      }
//      _orders = loadedOrders.reversed.toList();
//      notifyListeners();
//    }
    catch (error) {
      throw (error);
    }
  }

  Future<void> fetchSingleOrder(int orderId) async {
    final url = 'http://new.bepari.net/demo/api/V1.0/accounts/invoice/view-invoice/$orderId';
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
        totalDue: allOrders['total_due'].toDouble(),
         dateTime: DateTime.parse(allOrders['delivery_date']),
        invoiceAmount: allOrders['invoice_amount'].toDouble(),
        invoiceItem: (allOrders['invoice_details'] as List<dynamic>).map((item) => InvoiceItem(
          id: item['id'],
          productID: item['product_id'],
          unitPrice: item['unit_price'].toDouble(),
          quantity: item['quantity'],
          productName: item['product_name']
        )).toList(),

//          for(int i = 0; i<allOrders['invoice_details'].length; i++){}
      );
    _orderItem = orderItem;
    notifyListeners();
  }
}