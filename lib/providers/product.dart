import 'package:flutter/foundation.dart';


class Product with ChangeNotifier {
  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final String unit;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.category,
    @required this.description,
    @required this.price,
    @required this.unit,
    @required this.imageUrl,
    this.isFavorite = false,
  });


  void toggleFavoriteStatus(){
    isFavorite = !isFavorite;
    notifyListeners();
  }
}


