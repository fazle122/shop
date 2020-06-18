import 'package:flutter/material.dart';
import 'package:shoptempdb/data_helper/api_service.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [];
  var _showFavoritesOnly = false;

  List<Product> get items {
//    return [..._items];
    return [..._items];
  }

  Future<List<Product>> fetchAndSetProducts(int pageCount) async {
    print('test');
    var url =
        'http://new.bepari.net/demo/api/V1.0/product-catalog/product/list-product?page=$pageCount';
    try {
      final response = await http.get(url);
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
          price: allProduct[i]['unit_price'].toDouble(),
          isNonInventory: allProduct[i]['is_non_inventory'],
          discount: allProduct[i]['discount_amount'].toDouble(),
          discountType: allProduct[i]['discount_type'],
          discountId: allProduct[i]['discount_id'],
          imageUrl: ApiService.CDN_URl + 'product-catalog-images/product/' +allProduct[i]['thumb_image'],
//          imageUrl: 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
        );
        loadedProducts.add(product);
      }
      _items = loadedProducts;
      notifyListeners();
      return  _items;
    } catch (error) {
      throw (error);
    }
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }


}
