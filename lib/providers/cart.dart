import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shoptempdb/utility/local_db_helper.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final String imgUrl;
  final int quantity;
  final double price;
  final double vatRate;
  final int isNonInventory;
  final double discount;
  final String discountType;
  final String discountId;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.imgUrl,
    @required this.quantity,
    @required this.price,
    @required this.vatRate,
    @required this.isNonInventory,
    @required this.discount,
    @required this.discountType,
    @required this.discountId,
  });

  factory CartItem.fromJson(Map<String, dynamic> data) => new CartItem(
    id: data["id"].toString(),
    productId: data["productId"],
    title: data["title"],
    imgUrl: data["imageUrl"],
    quantity: data["quantity"],
    price:data['price'].toDouble(),
    vatRate:data['vatRate'] != null ?data['vatRate'].toDouble():0.0,
    isNonInventory: data['isNonInventory'],
    discount: data['discount'].toDouble(),
    discountType: data['discountType'],
    discountId: data['discountId'],

  );



  String get cartItemId => id;
  String get cartItemProductId => productId;
  String get cartItemTitle => title;
  int get cartItemQuantity => quantity;
  double get cartItemPrice => price;
  double get cartVatRate => vatRate;
  int get cartItemIsNonInventory => isNonInventory;
  double get cartItemDiscount => discount;
  String get cartItemDiscountType => discountType;
  String get cartItemDiscountId => discountId;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['productID'] = productId;
    map['title'] = title;
    map['imageUrl'] = title;
    map['quantity'] = quantity;
    map['price'] = price;
    map['vatRate'] = vatRate;
    map['isNonInventory'] = isNonInventory;
    map['discount'] = discount;
    map['discountType'] = discountType;
    map['discountId'] = discountId;

    return map;
  }

}


class Cart with ChangeNotifier {

  String id;
  CartItem cartItem;
  Cart({this.id,this.cartItem});


  List<CartItem> _items = [];
  double _deliveryCharge =0.0;
  double _maxDeliveryRange =0.0;
  double _minDeliveryCharge =0.0;



  List<CartItem> get items {
    return [..._items];
  }

  int get itemCount{
    return _items.length;
  }

  double get totalAmount{
    var total = 0.0;
      _items.forEach((item){
        total += item.price.toDouble() * item.quantity;
    });

    return total;
  }

  double get deliveryCharge{
    return _deliveryCharge;
  }

  set deliveryCharge(value){
    _deliveryCharge = value;
    notifyListeners();
  }

  double get maxDeliveryRange{
    return _maxDeliveryRange;
  }

  set maxDeliveryRange(value){
    _maxDeliveryRange = value;
    notifyListeners();
  }

  double get minDeliveryCharge{
    return _minDeliveryCharge;
  }

  set minDeliveryCharge(value){
    _minDeliveryCharge = value;
    notifyListeners();
  }

  CartItem findById(String id) {
    return _items.firstWhere((item) => item.id == id , orElse: () => null);
  }

  Future<void> fetchAndSetCartItems() async {
    final dataList = await DBHelper.getData('cartTable');
    _items = dataList
        .map(
          (item) => CartItem(
        id: item['id'].toString(),
        productId: item['productId'],
        title: item['title'],
        imgUrl: item['imageUrl'],
        quantity: item['quantity'],
        price: item['price'].toDouble(),
        vatRate: item['vatRate'] != null ?item['vatRate'].toDouble():0.0,
        isNonInventory: item['isNonInventory'],
        discount: item['discount'] != null ?item['discount'].toDouble():0.0,
        discountType: item['discountType'],
        discountId: item['discountId'],
      ),
    ).toList();
    notifyListeners();
  }

  Future<void> addItem(
      String productId,
      String title,
      String imgUrl,
      double price,
      double vatRate,
      int isNonInventory,
      double discount,
      String discountId,
      String discountType)  async {
    bool item = await DBHelper.isProductExist('cartTable',productId);
    if(!item) {
      await DBHelper.insert('cartTable', {
        'productId': productId,
        'title': title,
        'imageUrl': imgUrl,
        'quantity': 1,
        'price': price,
        'vatRate':vatRate,
        'isNonInventory': isNonInventory,
        'discount': discount,
        'discountType': discountType,
        'discountId':  discountId,
      });
    }else{
      await DBHelper.increaseItemQuantity('cartTable',productId);
    }
    fetchAndSetCartItems();

  }

  Future<void> removeSingleItem(String productId) async{
    CartItem cartData= await DBHelper.getSingleData('cartTable',productId);
    if(cartData.quantity == 1) {
      await DBHelper.deleteCartItm('cartTable',productId);
    }else{
      await DBHelper.decreaseItemQuantity('cartTable',productId);
    }
    fetchAndSetCartItems();
  }

  Future<void> removeCartItemRow(String productId) async{
    await DBHelper.deleteCartItm('cartTable',productId);
    fetchAndSetCartItems();
  }

  void clearCartTable(){
    DBHelper.clearCart('cartTable');
    _items = [];
    notifyListeners();
  }

}
