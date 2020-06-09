import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {

  String id;
  CartItem cartItem;

  Cart({this.id,this.cartItem});

  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

//  List<CartItem> _items = [];
//
//  List<CartItem> get items{
//    return [...items];
//  }

  int get itemCount{
    return _items.length;
  }

  double get totalAmount{
    var total = 0.0;
    _items.forEach((key,cartItem){
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }


  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(productId, (existingCartItem) =>
          CartItem(id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1));
    } else {
      _items.putIfAbsent(productId, () =>
          CartItem(
              id: productId,
              title: title,
              price: price,
              quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String productId){
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId){
    if(!items.containsKey(productId)){
      return;
    }
    if(_items[productId].quantity > 1){
      _items.update(productId, (existingCartItem) => CartItem(
        id: existingCartItem.id,
        title: existingCartItem.title,
        price: existingCartItem.price,
        quantity: existingCartItem.quantity -1
      ));
    }else{
      _items.remove(productId);
    }
    notifyListeners();

  }

  void clear(){
    _items ={};
    notifyListeners();
  }
}