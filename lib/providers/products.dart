import 'package:flutter/material.dart';
import 'package:shoptempdb/data_helper/api_service.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Products with ChangeNotifier {

  List<Product> _items = [];
  var _showFavoritesOnly = false;

  List<Product> get items {
    return [..._items];
  }


  Future<void> fetchAndSetProducts() async {
    var url = 'http://new.bepari.net/demo/api/V1/product-catalog/product/list-product';
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      var allProduct = data['data']['data'];
      for(int  i=0; i<allProduct.length;i++){
        final Product product = Product(
          id: allProduct[i]['id'].toString(),
          title: allProduct[i]['name'],
//          category: allProduct[i]['category_name'],
          category: allProduct[i]['product_category_id'].toString(),
          description: allProduct[i]['description'],
          unit: allProduct[i]['unit_name'],
          price: double.parse(allProduct[i]['unit_price']),
          imageUrl: 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
        );
        loadedProducts.add(product);
      }
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }


//  Future<void> fetchProductsCategory() async {
//    var url = 'http://new.bepari.net/demo/api/V1/product-catalog/product-category/list-product-category';
//    try {
//      final response = await http.get(url);
//      final data = json.decode(response.body) as Map<String, dynamic>;
//      if (data == null) {
//        return;
//      }
//      final List<ProductCategory> allCategory = [];
//      var catData = data['data']['data'];
//      for(int  i=0; i<catData.length;i++){
//        final ProductCategory cats = ProductCategory(
//          id: catData[i]['id'].toString(),
//          name: catData[i]['name'],
//          parents: catData[i]['parents'],
//          parentsName: catData[i]['parents_names'],
//        );
//        allCategory.add(cats);
//      }
//      _categories = allCategory;
//      notifyListeners();
//    } catch (error) {
//      throw (error);
//    }
//  }


  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void addProduct(Product product) {
    final newProduct = Product(
      title: product.title,
      price: product.price,
      description: product.description,
      imageUrl: product.imageUrl,
      id: DateTime.now().toString(),
    );
    _items.add(newProduct);
//    _items.insert(0, newProduct);  // at the start of the list
    notifyListeners();
  }

  void updateProduct(String id, Product newProduct) {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('..');
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
