import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shoptempdb/utility/local_db_helper.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;
  final int isNonInventory;
  final double discount;
  final String discountType;
  final String discountId;
//  final double perUnitDiscount;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
    @required this.isNonInventory,
    @required this.discount,
    @required this.discountType,
    @required this.discountId,
//    @required this.perUnitDiscount,
  });

  factory CartItem.fromJson(Map<String, dynamic> data) => new CartItem(
    id: data["id"].toString(),
    productId: data["productId"],

    title: data["title"],
    quantity: data["quantity"],
    price:data['price'].toDouble(),
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
    map['quantity'] = quantity;
    map['price'] = price;
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
//    notifyListeners();
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
        quantity: item['quantity'],
        price: item['price'].toDouble(),
        isNonInventory: item['isNonInventory'],
        discount: item['discount'] != null ?item['discount'].toDouble():0.0,
        discountType: item['discountType'],
        discountId: item['discountId'],

      ),
    ).toList();
    notifyListeners();
  }

  Future<void> addItem(String productId,
      String title,
      double price,
      int isNonInventory,
      double discount,
      String discountId,
      String discountType)  async {

    bool item = await DBHelper.isProductExist(productId);


    if(!item) {
      await DBHelper.insert('cartTable', {
//      'id': newPlace.id,
        'productId': productId,
        'title': title,
        'quantity': 1,
        'price': price,
        'isNonInventory': isNonInventory,
        'discount': discount,
        'discountType': discountType,
        'discountId':  discountId,
      });
    }else{
      await DBHelper.increaseItemQuantity('cartTable',productId);
    }
//    notifyListeners();

    fetchAndSetCartItems();

  }

  Future<void> removeSingleItem(String productId) async{

    CartItem cartData= await DBHelper.getSingleData(productId);

    if(cartData.quantity == 1) {
      await DBHelper.deleteCartItm(productId);
    }else{
      await DBHelper.decreaseItemQuantity(productId);
    }
//    notifyListeners();

    fetchAndSetCartItems();
  }

  Future<void> removeCartItemRow(String productId) async{
    await DBHelper.deleteCartItm(productId);
//    notifyListeners();

    fetchAndSetCartItems();
  }

  void clearCartTable(){
    DBHelper.clearCart();
    _items = [];
    notifyListeners();
  }

  double getDiscount(double discount, String discountType,double unitPrice,int quantity){
//    double discountAmount;
//    if(discount != 0.0){
//      if(discountType == 'percent'){
//        discountAmount =(discount/100);
//        discountAmount = unitPrice * discountAmount;
//      }
//      else if(discountType == 'amount'){
//        discountAmount = discount*quantity;
//      }
//    }else{
//      discountAmount = 0.0;
//    }
//    return discountAmount;
//  }
//
////  Future<void> fetchAndSetCartItems() async {
////
////    try {
////      final data = db.getAllCartItems();
////      if (data == null) {
////        return;
////      }
////      final List<CartItem> loadedProducts = [];
////
//////      _items = loadedProducts;
////      notifyListeners();
////    } catch (error) {
////      throw (error);
////    }
  }

  void removeItem(String productId){
//    _items.remove(productId);
//    notifyListeners();
  }

//  void clear(){
//    _items = [];
//    notifyListeners();
//  }
}







//class Cart with ChangeNotifier {
//
//  String id;
//  CartItem cartItem;
//
//  Cart({this.id,this.cartItem});
//
//  Map<String, CartItem> _items = {};
//
//  Map<String, CartItem> get items {
//    return {..._items};
//  }
//
////  List<CartItem> _items = [];
////
////  List<CartItem> get items{
////    return [...items];
////  }
//
//  int get itemCount{
//    return _items.length;
//  }
//
//  double get totalAmount{
//    var total = 0.0;
//    _items.forEach((key,cartItem){
//      total += cartItem.price * cartItem.quantity;
//    });
//    return total;
//  }
//
//  double getDiscount(double discount, String discountType,double unitPrice,int quantity){
//    double discountAmount;
//    if(discount != 0.0){
//      if(discountType == 'percent'){
//        discountAmount =(discount/100);
//        discountAmount = unitPrice * discountAmount;
//      }
//      else if(discountType == 'amount'){
//        discountAmount = discount*quantity;
//    }
//    }else{
//    discountAmount = 0.0;
//    }
//    return discountAmount;
//  }
//
//  void addItem(String productId, String title, double price,int isNonInventory,double discount,String discountId,String discountType) {
//    if (_items.containsKey(productId)) {
//      _items.update(productId, (existingCartItem) =>
//          CartItem(id: existingCartItem.id,
//              title: existingCartItem.title,
//              price: existingCartItem.price,
//              isNonInventory: existingCartItem.isNonInventory,
////              discount: existingCartItem.discount,
//              discount: getDiscount(existingCartItem.discount.toDouble(), existingCartItem.discountType, existingCartItem.price.toDouble(),existingCartItem.quantity+1),
//              discountId: existingCartItem.discountId,
//              discountType: existingCartItem.discountType,
//              quantity: existingCartItem.quantity + 1));
//    } else {
//      _items.putIfAbsent(productId, () =>
//          CartItem(
//              id: productId,
//              title: title,
//              price: price,
//              isNonInventory: isNonInventory,
////              discount: discount,
//              discount: getDiscount(discount.toDouble(), discountType,price.toDouble(), 1),
//              discountId: discountId,
//              discountType: discountType,
//              quantity: 1));
//    }
//    notifyListeners();
//  }
//
//
//  void removeItem(String productId){
//    _items.remove(productId);
//    notifyListeners();
//  }
//
//  void removeSingleItem(String productId){
//    if(!items.containsKey(productId)){
//      return;
//    }
//    if(_items[productId].quantity > 1){
//      _items.update(productId, (existingCartItem) => CartItem(
//        id: existingCartItem.id,
//        title: existingCartItem.title,
//        price: existingCartItem.price,
//          isNonInventory: existingCartItem.isNonInventory,
//          quantity: existingCartItem.quantity -1
//      ));
//    }else{
//      _items.remove(productId);
//    }
//    notifyListeners();
//
//  }
//
//  void clear(){
//    _items ={};
//    notifyListeners();
//  }
//}