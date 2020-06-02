import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shoptempdb/providers/product.dart';

class ProductCategoryItem {
  final String id;
  final String name;
  final String parents;
  final String parentsName;

  ProductCategoryItem({
    @required this.id,
    @required this.name,
    @required this.parents,
    @required this.parentsName,
  });
}

class ProductCategories with ChangeNotifier {
  List<ProductCategoryItem> _categories = [];

  List<ProductCategoryItem> get getCategories {
    return [..._categories];
  }

  Future<void> fetchProductsCategory() async {
    var url = 'http://new.bepari.net/demo/api/V1/product-catalog/product-category/list-product-category';
    final List<ProductCategoryItem> allCategory = [];
    final response = await http.get(url);
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data == null) {
      return;
    }
    var catData = data['data']['data'];
    for (int i = 0; i < catData.length; i++) {
      final ProductCategoryItem cats = ProductCategoryItem(
        id: catData[i]['id'].toString(),
        name: catData[i]['name'],
        parents: catData[i]['parents'],
        parentsName: catData[i]['parents_names'],
      );
      allCategory.add(cats);
    }
    _categories = allCategory;
    notifyListeners();
  }

//  Future<void> fetchProductsCategory() async {
//    var url = 'http://new.bepari.net/demo/api/V1/product-catalog/product-category/list-product-category';
//    try {
//      final response = await http.get(url);
//      final data = json.decode(response.body) as Map<String, dynamic>;
//      if (data == null) {
//        return;
//      }
//      final List<ProductCategoryItem> allCategory = [];
//      var catData = data['data']['data'];
//      for(int  i=0; i<catData.length;i++){
//        final ProductCategoryItem cats = ProductCategoryItem(
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

}
