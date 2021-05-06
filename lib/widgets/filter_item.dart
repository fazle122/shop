import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';


class DataSearch extends SearchDelegate<String> {
  final bool _showList;
  int PageCount = 1;
  bool _isInit= false;

  DataSearch(this._showList);

  getDeliveryCharge(BuildContext context,Cart cart,double totalAmount) async{
      List deliveryChargeMatrix = [];

      await Provider.of<Products>(context,listen: false).fetchDeliveryCharMatrix().then((data){
        deliveryChargeMatrix = data['range'];
        for(int i=0;i<deliveryChargeMatrix.length;i++){
          if(i == 0 && totalAmount<=deliveryChargeMatrix[i]['max']){
            // setState(() {
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
            // });
          }else if( i>0 && totalAmount >= deliveryChargeMatrix[i]['min']){
            // setState(() {
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
            // });
          }else if( i>0){
            // setState(() {
            cart.maxDeliveryRange = deliveryChargeMatrix[i]['min'].toDouble();
            // cart.minDeliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
            // });
          }
        }
      });
  }

  List<TextSpan> highlightOccurrences(String source, String query) {
    if (query == null || query.isEmpty || !source.toLowerCase().contains(query.toLowerCase())) {
      return [ TextSpan(text: source) ];
    }
    final matches = query.toLowerCase().allMatches(source.toLowerCase());

    int lastMatchEnd = 0;

    final List<TextSpan> children = [];
    for (var i = 0; i < matches.length; i++) {
      final match = matches.elementAt(i);

      if (match.start != lastMatchEnd) {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, match.start),
        ));
      }

      children.add(TextSpan(
        text: source.substring(match.start, match.end),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ));

      if (i == matches.length - 1 && match.end != source.length) {
        children.add(TextSpan(
          text: source.substring(match.end, source.length),
        ));
      }

      lastMatchEnd = match.end;
    }
    return children;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () async{
          close(context, null);
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.trim().isEmpty ? SizedBox(width: 0.0,height: 0.0,): FutureBuilder(
      future: Provider.of<Products>(context).searchAndSetProducts(pageCount:PageCount,keyword: query.trim()),
      builder: (context, snapshot) {
        return Consumer<Products>(
          builder: (context, data,child) =>
              ListView.builder(
                itemCount: data.items.length,
                itemBuilder: (context, i) => ListTile(
                  onTap: () {
                    showResults(context);
                  },
                  title: RichText(
                    text: TextSpan(
                      children: highlightOccurrences(data.items[i].title, query),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
        );

      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    List<Product> products = productsData.items.where((data) => data.title.toLowerCase().contains(query.toLowerCase())).toList();
    return query.isEmpty? SizedBox(width: 0.0,height: 0.0,):
    ProductTile(products: products,query:query);
  }

}

enum ProductLoadMoreStatus { LOADING, STABLE }

class ProductTile extends StatefulWidget {
  final List<Product> products;
  final String query;

  ProductTile({Key key, this.products,this.query}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProductTileState();
}

class ProductTileState extends State<ProductTile> {
  ProductLoadMoreStatus loadMoreStatus = ProductLoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<Product> searchProducts;
  int currentPageNumber;

  getDeliveryCharge(Cart cart,double totalAmount) async{
    List deliveryChargeMatrix = [];
    await Provider.of<Products>(context,listen: false).fetchDeliveryCharMatrix().then((data){
      deliveryChargeMatrix = data['range'];
      for(int i=0;i<deliveryChargeMatrix.length;i++){
        if(i == 0 && totalAmount<=deliveryChargeMatrix[i]['max']){
          setState(() {
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
          });
        }else if( i>0 && totalAmount >= deliveryChargeMatrix[i]['min']){
          setState(() {
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();

          });
        }else if( i>0){
          setState(() {
            cart.maxDeliveryRange = deliveryChargeMatrix[i]['min'].toDouble();
            // cart.minDeliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
          });
        }
      }
    });
  }

  @override
  void initState() {
    searchProducts = widget.products;
    // currentPageNumber = widget.products.lastPageCount;
    currentPageNumber = 1;
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget ProductListTile({Product product}){
    final cart = Provider.of<Cart>(context);
    Map<String,dynamic> newCartItem = Map.fromIterable(cart.items, key: (v) => v.productId, value: (v) => v.quantity);
    return Card(
        shape: BeveledRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(8.0)),
        ),
        child:
        ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                product.title,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 05.0,),
            ],
          ),
          subtitle: Text('BDT ' + product.price.toString() + '/' + product.unit,style: TextStyle(fontSize: 15.0,color: Colors.grey),),
          leading: Hero(
            tag: product.id,
            child: FadeInImage(
              image: NetworkImage(product.imageUrl),
              height: 70.0,
              width: 50.0,
              fit: BoxFit.contain,
              placeholder: AssetImage('assets/products.png'),
            ),
          ),
          trailing:
          Container(
            width: 110.0,
            child: newCartItem.keys.contains(product.id) ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  color:Colors.red,
                  onPressed: () async{
                    await cart.addItem(
                        product.id,
                        product.title,
                        product.imageUrl,
                        product.price,
                        product.vatRate,
                        product.isNonInventory,
                        product.discount,
                        product.discountId,
                        product.discountType);
                    Future.delayed(const Duration(milliseconds: 500), () async{
                      await getDeliveryCharge(cart,cart.totalAmount);

                    });

                  },
                ),
                Text(cart.items.firstWhere((d) => d.productId == product.id).quantity.toString(),style: TextStyle(fontSize: 20.0),),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,),
                  color: Colors.red,
                  onPressed: () async{
                    await cart.removeSingleItem(product.id);
                    Future.delayed(const Duration(milliseconds: 500), () async{
                      await getDeliveryCharge(cart,cart.totalAmount);

                    });
                  },
                ),
              ],
            ):Container(
                margin: EdgeInsets.only(top:5.0),
                // padding: EdgeInsets.all(5.0),
                width: 90.0,
                height: 20.0,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor
                ),
                child: InkWell(
                  child: Center(child:Text('Add to cart',style: TextStyle(fontSize: 12.0,color: Colors.white,fontWeight: FontWeight.bold),),),
                  onTap: () async{
                    await cart.addItem(
                        product.id,
                        product.title,
                        product.imageUrl,
                        product.price,
                        product.vatRate,
                        product.isNonInventory,
                        product.discount,
                        product.discountId,
                        product.discountType);
                    Future.delayed(const Duration(milliseconds: 500), () async{
                      await getDeliveryCharge(cart,cart.totalAmount);


                    });
                  },
                )
            ),
            // IconButton(
            //   color: Theme.of(context).accentColor,
            //   icon: Icon(Icons.shopping_cart),
            //   onPressed: () async{
            //     await cart.addItem(
            //         product.id,
            //         product.title,
            //         product.price,
            //         product.isNonInventory,
            //         product.discount,
            //         product.discountId,
            //         product.discountType);
            //     Future.delayed(const Duration(milliseconds: 500), () async{
            //       await getDeliveryCharge(cart,cart.totalAmount);
            //
            //
            //     });
            //   },
            // ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: product.id);
          },
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        onNotification: onNotification,
        child:
        ListView.builder(
            padding: EdgeInsets.only(top: 5.0),
            controller: scrollController,
            itemCount: searchProducts.length,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              if (index == searchProducts.length) {
                return _buildProgressIndicator();
              } else {
                return ProductListTile(product: searchProducts[index]);
              }
            })
        );
  }

  bool onNotification(ScrollNotification notification) {
    // if (notification is ScrollUpdateNotification) {
    //   if (scrollController.position.maxScrollExtent > scrollController.offset &&
    //       scrollController.position.maxScrollExtent - scrollController.offset <=
    //           50) {
    if(scrollController.position.pixels ==
        scrollController.position.maxScrollExtent){
        if (loadMoreStatus != null &&
            loadMoreStatus == ProductLoadMoreStatus.STABLE) {
          loadMoreStatus = ProductLoadMoreStatus.LOADING;
          Provider.of<Products>(context, listen: false)
              .searchAndSetProducts(pageCount:currentPageNumber + 1,keyword: widget.query.trim())
              .then((data) {
            currentPageNumber = currentPageNumber + 1;
            loadMoreStatus = ProductLoadMoreStatus.STABLE;
            setState(() => searchProducts.addAll(data));
            // if (data == null || data.isEmpty) {
            //   if (searchProducts.isNotEmpty) animateScrollBump();
            //   if (searchProducts.isEmpty) {
            //     setState(() {});
            //   }
            // } else {
            //   currentPageNumber = currentPageNumber + 1;
            //   loadMoreStatus = ProductLoadMoreStatus.STABLE;
            //   setState(() => searchProducts.addAll(data));
            // }
          });
        }
      }
    // }
    return true;
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          // opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void animateScrollBump() {
    double edge = 50.0;
    double offsetFromBottom = scrollController.position.maxScrollExtent -
        scrollController.position.pixels;
    if (offsetFromBottom < edge) {
      scrollController.animateTo(
          scrollController.offset - (edge - offsetFromBottom),
          duration: new Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }

}
