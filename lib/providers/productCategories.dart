import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shoptempdb/utility/api_service.dart';



class ProductCategoryItem {
  final String id;
  final String name;
  final String parents;
  final String parentsName;
  final String categoryImage;

  ProductCategoryItem({
    @required this.id,
    @required this.name,
    @required this.parents,
    @required this.parentsName,
    @required this.categoryImage,
  });
}

class ProductCategories with ChangeNotifier {
  List<ProductCategoryItem> _categories = [];

  List<ProductCategoryItem> get getCategories {
    return [..._categories];
  }

  Future<void> fetchProductsCategory() async {
    var url = ApiService.BASE_URL +  'api/V1.0/product-catalog/product-category/list-product-category?page_size=all';
    final List<ProductCategoryItem> allCategory = [];
    final response = await http.get(url);
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data == null) {
      return;
    }
    var catData = data['data'];
    for (int i = 0; i < catData.length; i++) {
      final ProductCategoryItem cats = ProductCategoryItem(
        id: catData[i]['id'].toString(),
        name: catData[i]['name'],
        parents: catData[i]['parents'],
        parentsName: catData[i]['parents_names'],
        categoryImage: catData[i]['thumb_image'],
      );
      allCategory.add(cats);
    }
    _categories = allCategory;
    notifyListeners();
  }

}
