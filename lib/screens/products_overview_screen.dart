import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/cart_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/badge.dart';
import 'package:shoptempdb/widgets/filter_item.dart';
import 'package:shoptempdb/widgets/product_item_grid_view.dart';
import 'package:shoptempdb/widgets/product_item_list_view.dart';
import '../base_state.dart';
import 'package:toast/toast.dart';



class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = 'all-products';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends BaseState<ProductsOverviewScreen> {
  var _isInit = true;
  var _isLoading = false;

  ScrollController _scrollController = new ScrollController();
  int pageCount = 1;
  int lastPage;
  String keyword = '';
  int oldPageCount;
  DateTime currentBackPressTime;
  int lastItemId = 0;
  List<Product> finalProduct = [];
  bool isPerformingRequest = false;

  @override
  void initState() {
    if (_isInit) {
      getDeliveryCharge();
    }
    super.initState();
  }


  @override
  void didChangeDependencies() {
    final products = Provider.of<Products>(context, listen: false);
    final cat = ModalRoute.of(context).settings.arguments as String;
    if (pageCount == 1) {
      if (_isInit) {
        setState(() {
          _isLoading = true;
        });
        if (cat != null) {
          Provider.of<Products>(context, listen: false)
              .fetchAndSetProducts(pageCount, int.parse(cat))
              .then((data) {
            setState(() {
              finalProduct = data;
              lastPage = products.lastPageNo;
              oldPageCount = 0;
              _isLoading = false;
            });
          });
        } else {
          Provider.of<Products>(context, listen: false)
              .fetchAndSetProducts(pageCount, 0)
              .then((data) {
            setState(() {
              finalProduct = data;
              lastPage = products.lastPageNo;
              oldPageCount = 0;
              _isLoading = false;
            });
          });
        }
      }
      _isInit = false;
    }

    _scrollController.addListener(() {
      if (pageCount - oldPageCount == 1 || oldPageCount - pageCount == 1) {
        _isInit = true;
        if (pageCount < lastPage) if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            pageCount += 1;
          });
          getData();
        }
      }
    });

    super.didChangeDependencies();
  }

  getDeliveryCharge() async{
    List deliveryChargeMatrix = [];
    final cart = await Provider.of<Cart>(context,listen: false);
    await Provider.of<Products>(context,listen: false).fetchDeliveryCharMatrix().then((data){
      deliveryChargeMatrix = data['range'];
      for(int i=0;i<deliveryChargeMatrix.length;i++){
        if(i == 0 && cart.totalAmount<=deliveryChargeMatrix[i]['max']){
          cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
        }else if( i>0 && cart.totalAmount >= deliveryChargeMatrix[i]['min']){
          cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
        }
      }
    });
  }


  List<Product> getData() {
    final cat = ModalRoute.of(context).settings.arguments as String;
    if (_isInit) {
      if (!isPerformingRequest) {
        setState(() => isPerformingRequest = true);
      }
      if (cat != null) {
        Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts(pageCount, int.parse(cat))
            .then((data) {
          isPerformingRequest = false;
          if (data == null || data.isEmpty) {
            if (finalProduct.isNotEmpty) animateScrollBump();
            if (finalProduct.isEmpty) {
              setState(() {});
            }
          } else {
            setState(() {
              oldPageCount += 1;
              finalProduct.addAll(data);
              lastItemId = int.parse(data.last.id);
            });
          }

        });
      } else {
        Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts(pageCount, 0)
            .then((data) {
          isPerformingRequest = false;
          if (data == null || data.isEmpty) {
            if (finalProduct.isNotEmpty) animateScrollBump();
            if (finalProduct.isEmpty) {
              setState(() {});
            }
          } else {
            setState(() {
              oldPageCount += 1;
              finalProduct.addAll(data);
              lastItemId = int.parse(data.last.id);
            });
          }

        });
      }
    }
    _isInit = false;
    return finalProduct;
  }

  void animateScrollBump() {
    double edge = 50.0;
    double offsetFromBottom = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (offsetFromBottom < edge) {
      _scrollController.animateTo(
          _scrollController.offset - (edge - offsetFromBottom),
          duration: new Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Toast.show("Press back again to exit the app", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final product = Provider.of<Products>(context,listen:false);
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        actions: <Widget>[
          IconButton(
        icon: product.isList
                ? Icon(
                    Icons.list,
                    size: 25.0,
                  )
                : Icon(
                    Icons.grid_on,
                    size: 20.0,
                  ),
            onPressed: () {
              if (!mounted) return;
             if(product.isList == true){
               setState(() {
                 product.isList = false;
               });
             }else{
               setState(() {
                 product.isList = true;
               });
             }
            },
          ),
          Consumer<Cart>(
            builder: (context, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(product.isList));
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body:WillPopScope(
        onWillPop: onWillPop,
        child:  _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
          child: Column(
            children: <Widget>[
              Expanded(
                  child: queryItemListDataWidget(context,product)),

              Consumer<Cart>(
                builder: (context, cartData, child) =>
                cart.items.length > 0
                    ?
                InkWell(
                  child:Container(
                    height: 50.0,
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width *
                                5 /
                                7,
                            padding:
                            EdgeInsets.only(left: 20.0, top: 2.0),
                            color: Color(0xffFB0084),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                // Text('SubTotal: ' + cartData.totalAmount.toStringAsFixed(2) + ' BDT'),
                                // Text('Delivery charge: ' + cartData.deliveryCharge.toString() + ' BDT'),
                                // Text('Total amount : ' + (cartData.totalAmount + cartData.deliveryCharge).toStringAsFixed(2) + ' BDT'),
                                Text(' View My Basket',style: TextStyle(fontSize:18.0,fontWeight: FontWeight.bold,color: Colors.white),)
                              ],
                            )),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width:
                          MediaQuery.of(context).size.width * 2 / 7,
                          color: Color(0xffB40060),
                          child: Center(
                              // child: Text('Check out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              child: Text((cartData.totalAmount + cartData.deliveryCharge).toStringAsFixed(2) + ' BDT',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                          ),
                        ),
                      ],
                    )),
                  onTap: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },): SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
              )

            ],
          ),
        )
      )
    );
  }

  Widget queryItemListDataWidget(BuildContext context,Products products) {
    if (finalProduct.isNotEmpty) //has data & performing/not performing
      return ProductItemList(
        productListItems: finalProduct,
        scrollController: _scrollController,
        isPerformingRequest: isPerformingRequest,
        showList: products.isList,
      );
    if (isPerformingRequest)
      return Center(
        child: CircularProgressIndicator(),
      );

    return Center(
      child: Text('no product found'),
    );
  }


}


class ProductItemList extends StatelessWidget{

  final List<Product> productListItems;
  final ScrollController scrollController;
  final bool isPerformingRequest;
  final bool showList;

  ProductItemList(
      {this.productListItems, this.scrollController, this.isPerformingRequest,this.showList});

  @override
  Widget build(BuildContext context) {
    return Container
      (child: !showList
          ? productListItems != null && productListItems.length > 0
          ? ListView.builder(
          // padding: const EdgeInsets.all(0.0),
          controller: scrollController,
          itemCount: productListItems.length+1,
          itemBuilder: (context, i) {
            if (i == productListItems.length) {
              return _buildProgressIndicator();
            } else {
              return ChangeNotifierProvider.value(
                value: productListItems[i],
                child: ProductItemListView(),
              );
            }
          })
          : Center(
        child: Text('No item found'),
      )
          : productListItems != null && productListItems.length > 0
          ?

          GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(10.0),
          itemCount: productListItems.length+1,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4 / 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, i) {
            if (i == productListItems.length) {
              return _buildProgressIndicator1();
            } else {
              return ChangeNotifierProvider.value(
              value: productListItems[i],
              child: ProductItemGridView(),
              );
              }
          }
              )
          : Center(
        child: Text('No item found'),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator1() {
    return Padding(
      padding: const EdgeInsets.only(top:50,left:160),
      child: Center(
        child: Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}


