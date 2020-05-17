import 'package:flutter/material.dart';
import 'package:shoptempdb/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
        id: 'p1',
        title: 'Cheese',
        category: 'Food',
        description: 'Made from fresh and pure milk!',
        price: 249.99,
        unit: '1 kg',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/f/ff/Grocery_store_in_Roma.jpg'),
    Product(
        id: 'p2',
        title: 'Bread',
        category: 'Food',
        description: 'Fresh and testy',
        price: 60.00,
        unit: '1 pound',
        imageUrl:
            'https://portcitydaily.com/wp-content/uploads/white-bread-4642686_1280-475x327.jpg'),
    Product(
        id: 'p3',
        title: 'Beef',
        category: 'Food',
        description: 'Bone less fresh meat',
        price: 499.99,
        unit: '1kg',
        imageUrl:
            'https://thumbs-prod.si-cdn.com/ktv3e7YSr3pKIEJx0DR_g8YINbk=/800x600/filters:no_upscale()/https://public-media.si-cdn.com/filer/12/ac/12aca10f-00dc-49fc-b0f7-a1d19244eb98/beef.jpg'),
    Product(
      id: 'p4',
      title: 'Fish',
      category: 'Food',
      description: 'Fresh and live fish',
      price: 450.99,
      unit: '1kg',
      imageUrl:
          'https://image.shutterstock.com/image-photo/fresh-fish-seafood-healthy-eating-260nw-1199983309.jpg',
    ),
    Product(
      id: 'p5',
      title: 'Chicken',
      category: 'Food',
      description: 'Poultry firm\'s chicken',
      price: 220.00,
      unit: '1kg',
      imageUrl:
          'https://sc01.alicdn.com/kf/UTB8hX3Qg0nJXKJkSaiyq6AhwXXa3.jpg_350x350.jpg',
    ),
    Product(
      id: 'p6',
      title: 'Egg',
      category: 'Food',
      description: 'Organic egg',
      price: 130.00,
      unit: '12 pcs',
      imageUrl:
          'https://cdn.britannica.com/s:700x500/94/151894-050-F72A5317/Brown-eggs.jpg',
    ),
    Product(
      id: 'p7',
      title: 'Spices',
      category: 'Grocery',
      description: 'Pure natural spices',
      price: 99.99,
      unit: '100 grms',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Spices_in_an_Indian_market.jpg/1200px-Spices_in_an_Indian_market.jpg',
    ),
    Product(
      id: 'p8',
      title: 'Milk',
      category: 'Food',
      description: 'Fresh dairy firm milk',
      price: 80.00,
      unit: '1 liter',
      imageUrl:
          'https://static.toiimg.com/thumb/msid-68670383,width-800,height-600,resizemode-75,imgsize-792974,pt-32,y_pad-40/68670383.jpg',
    ),
    Product(
      id: 'p9',
      title: 'Honey',
      category: 'Food',
      description: 'Honey of different types',
      price: 200.00,
      unit: '.5 kg',
      imageUrl:
          'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
    ),
    Product(
      id: 'p10',
      title: 'Rice',
      category: 'Grocery',
      description: 'Rice of various brand',
      price: 50.00,
      unit: '1kg',
      imageUrl: 'https://i.ytimg.com/vi/Vtujnb_k0YM/maxresdefault.jpg',
    ),
    Product(
      id: 'p11',
      title: 'Flour',
      category: 'Grocery',
      description: 'Flour of various brand',
      price: 70.00,
      unit: '1kg',
      imageUrl:
          'https://s3-ap-southeast-1.amazonaws.com/media.evaly.com.bd/watermarked/2018-04-06_230400.931670teerflourmaida2kg_5ab3b76e0ea0b-.6367.jpg',
    ),
    Product(
      id: 'p12',
      title: 'Oil',
      category: 'Grocery',
      description: 'Oil fo various brand',
      price: 90.00,
      unit: '1kg',
      imageUrl:
          'https://tbsnews.net/sites/default/files/styles/big_2/public/images/2019/12/17/oil.jpg',
    ),
  ];

  var _showFavoritesOnly = false;

  List<Product> get items {
    return [..._items];
  }

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
