import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shoptempdb/data_helper/api_service.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final String unit;
  final String imageUrl;
  final int isNonInventory;
  final double discount;
  final String discountId;
  final String discountType;
  final double perUnitDiscount;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.category,
    @required this.description,
    @required this.price,
    @required this.unit,
    @required this.imageUrl,
    @required this.isNonInventory,
    @required this.discount,
    @required this.discountId,
    @required this.discountType,
    @required this.perUnitDiscount,
    this.isFavorite = false,

  });

}

class Products with ChangeNotifier {
  List<Product> _items = [];
  int lastPageCount;
  bool _isList = false;
  var _showFavoritesOnly = false;

  Product _productItem;

  Product get singProductItem{
    return _productItem;
  }
  List<Product> get items {
//    return [..._items];
    return [..._items];
  }

  int get lastPageNo {
    return lastPageCount;
  }

  bool get isList{
    return _isList;
  }

  set isList(value){
    _isList = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchDeliveryCharMatrix() async {
    String url = ApiService.BASE_URL +
        'api/V1.0/accounts/invoice/send-delivery-charge-matrix';
    Dio dioService = Dio();
    dioService.options.headers = {
      'Content-Type': 'Application/json',
    };

    try {
      final Response response = await dioService.get(url);
      final responseData = response.data;
      if (response.statusCode == 200) {
        return responseData['data'];
      }
      return null;
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String, dynamic>> fetchDeliveryCharge(FormData formData) async {
    Dio dioService = new Dio();
    final url =
        ApiService.BASE_URL + 'api/V1.0/accounts/invoice/send-delivery-charge';

    dioService.options.headers = {
      'Content-Type': 'application/json',
    };
    try {
      final Response response = await dioService.post(
        url,
        data: formData,
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return responseData;
      }
        return null;
    } catch (error) {
      throw error;
    }
  }

  Future<List<Product>> fetchAndSetProducts(int pageCount, int catId) async {
    print('test');
    var url =
        'http://new.bepari.net/demo/api/V1.0/product-catalog/product/list-product?page_size=30&page=$pageCount&category_id=$catId';
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        return null;
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return null;
      }
      final List<Product> loadedProducts = [];
      var allProduct = data['data']['data'];
      for (int i = 0; i < allProduct.length; i++) {
        final Product product = Product(
          id: allProduct[i]['id'].toString(),
          title: allProduct[i]['name'],
//          category: allProduct[i]['category_name'],
          category: allProduct[i]['product_category_id'].toString(),
          description: allProduct[i]['description'],
          unit: allProduct[i]['unit_name'],
//          price: allProduct[i]['unit_price'].toDouble(),
          price: double.parse(allProduct[i]['unit_price']),
          isNonInventory: allProduct[i]['is_non_inventory'],
//          discount: allProduct[i]['discount_amount'].toDouble(),
          discount: allProduct[i]['discount_amount'] != null
              ? double.parse(allProduct[i]['discount_amount'])
              : 0,
          discountType: allProduct[i]['discount_type'],
          discountId: allProduct[i]['discount_id'],
          imageUrl: allProduct[i]['thumb_image'] != null
              ? ApiService.CDN_URl +
                  'product-catalog-images/product/' +
                  allProduct[i]['thumb_image']
              : 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
//          imageUrl: 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
        );
        loadedProducts.add(product);
      }
      lastPageCount = data['data']['last_page'];
      _items = loadedProducts;
      notifyListeners();
      return _items;
    } catch (error) {
      throw (error);
    }
  }

  Future<List<Product>> searchAndSetProducts({String keyword}) async {
    print('test');
    var url =
        'http://new.bepari.net/demo/api/V1.0/product-catalog/product/list-product?page_size=100&keyword=$keyword';
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        return null;
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return null;
      }
      final List<Product> loadedProducts = [];
      var allProduct = data['data']['data'];
      for (int i = 0; i < allProduct.length; i++) {
        final Product product = Product(
          id: allProduct[i]['id'].toString(),
          title: allProduct[i]['name'],
//          category: allProduct[i]['category_name'],
          category: allProduct[i]['product_category_id'].toString(),
          description: allProduct[i]['description'],
          unit: allProduct[i]['unit_name'],
//          price: allProduct[i]['unit_price'].toDouble(),
          price: double.parse(allProduct[i]['unit_price']),
          isNonInventory: allProduct[i]['is_non_inventory'],
//          discount: allProduct[i]['discount_amount'].toDouble(),
          discount: allProduct[i]['discount_amount'] != null
              ? double.parse(allProduct[i]['discount_amount'])
              : 0,
          discountType: allProduct[i]['discount_type'],
          discountId: allProduct[i]['discount_id'],
          imageUrl: allProduct[i]['thumb_image'] != null
              ? ApiService.CDN_URl +
                  'product-catalog-images/product/' +
                  allProduct[i]['thumb_image']
              : 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
//          imageUrl: ApiService.CDN_URl + 'product-catalog-images/product/' +allProduct[i]['thumb_image'],
//          imageUrl: 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
        );
        loadedProducts.add(product);
      }
      _items = loadedProducts;
      notifyListeners();
      return _items;
    } catch (error) {
      throw (error);
    }
  }

  Future<Product> fetchSingleProduct(int productId) async {
    final url = 'http://new.bepari.net/demo/api/V1.0/product-catalog/product/view-product/$productId';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final http.Response response = await http.get(
      url,
      headers: headers,
    );
    final extarctedData = json.decode(response.body) as Map<String, dynamic>;
    if(extarctedData == null){
      return null;
    }

    var product = extarctedData['data'];
    final Product selectedProduct = Product(
      id: product['id'].toString(),

      title: product['name'],
      category: product['product_category_id'].toString(),
      description: product['description'],
      unit: product['unit_name'],
      price: product['unit_price'].toDouble(),
      isNonInventory: product['is_non_inventory'],
      discount: product['discount_amount'] != null
          ? product['discount_amount'].toDouble()
          : 0.0,
      discountType: product['discount_type'],
      discountId: product['discount_id'],
      // imageUrl: product['thumb_image'] != null
      //     ? ApiService.CDN_URl + 'product-catalog-images/product/' + product['thumb_image']
      //     : 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
      imageUrl: 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
    );
    _productItem = selectedProduct;
    notifyListeners();
    return _productItem;

  }

//  List<Product> get favoriteItems {
//    return _items.where((prodItem) => prodItem.isFavorite).toList();
//  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }
}
