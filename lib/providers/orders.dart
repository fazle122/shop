import 'package:flutter/foundation.dart';
import 'package:shoptempdb/data_helper/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';



class OrderItem{
  final int id;
  final double invoiceAmount;
  final double totalDue;
//  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
   @required this.id,
   @required this.invoiceAmount,
    @required this.totalDue,
//  @required this.products,
   @required this.dateTime,
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
//    final url = 'http://new.bepari.net/demo/api/V1/accounts/invoice/list-invoice';
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
//  List<CartItem> _cartItems = [];

  final String authToken;
  final String userid;

  Orders(this.authToken,this.userid,this._orders);

  List<OrderItem> get orders{
    return [..._orders];
  }

//  List<CartItem> get cartItem{
//    return [..._cartItems];
//  }


  void addOrder(FormData formData) async{

    Dio dioService = new Dio();
    final url = ApiService.BASE_URL +  'api/V1/accounts/invoice/create-invoice';

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

  Future<void> fetchAndSetOrders() async {
    final url = 'http://new.bepari.net/demo/api/V1/accounts/invoice/list-invoice';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final http.Response response = await http.get(
      url,
      headers: headers,
    );
    final List<OrderItem> loadedOrders = [];
    final extarctedData = json.decode(response.body) as Map<String, dynamic>;
    if(extarctedData == null){
      return;
    }

    var allOrders = extarctedData['data']['invoices']['data'];
    for(int i=0; i<allOrders.length; i++){
      final OrderItem orders = OrderItem(
          id: allOrders[i]['id'],
          invoiceAmount: double.parse(allOrders[i]['invoice_amount']),
          totalDue: double.parse(allOrders[i]['total_due']),
          dateTime: DateTime.parse(allOrders[i]['invoice_date']),
      );
      loadedOrders.add(orders);
    }
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

//  Future<void> fetchSingleOrder(int orderId) async {
//    final url = 'http://new.bepari.net/demo/api/V1/accounts/invoice/view-invoice/$orderId';
//    Map<String, String> headers = {
//      'Authorization': 'Bearer ' + authToken,
//      'Content-Type': 'application/json',
//    };
//    final http.Response response = await http.get(
//      url,
//      headers: headers,
//    );
//    final List<CartItem> loadedCartItems = [];
//    final extarctedData = json.decode(response.body) as Map<String, dynamic>;
//    if(extarctedData == null){
//      return;
//    }
//
//    var allOrders = extarctedData['data']['invoice_details'];
//    for(int i=0; i<allOrders.length; i++){
//      final CartItem cartItem = CartItem(
//        id: allOrders[i]['id'].toString(),
//        title: allOrders[i]['product_name'],
////        quantity: int.parse(double.parse(allOrders[i]['quantity']).toString()),
//      );
//      loadedCartItems.add(cartItem);
//    }
//    _cartItems = loadedCartItems;
//    notifyListeners();
//  }
}