import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model ---------------------------------------------------

class SingleSelectCountry with ChangeNotifier {
  final List<String> _items = <String>[
    "Argentina",
    "Belgium",
    "Brazil",
    "Denmark",
    "England",
    "France",
    "Finland",
    "Germany",
    "Holland",
    "Ireland",
    "Norway",
    "Poland",
    "Scotland",
    "Spain",
    "Sweden",
    "Switzerland",
    "Wales",
  ];

  String _selectedItem;

  UnmodifiableListView<String> get items {
    return UnmodifiableListView(this._items);
  }

  String get selected {
    return this._selectedItem;
  }

  set selected(final String item) {
    this._selectedItem = item;
    this.notifyListeners();
  }
}

// User Interface ------------------------------------------

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    // The provider has to be in the widget tree higher than
    // both `CountryDropDown` and `UserOffers`.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SingleSelectCountry>(
          create: (final BuildContext context) {
            return SingleSelectCountry();
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Home Page'),
        ),
        body: Restrictions(),
      ),
    );
  }
}

class Restrictions extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return Column(
      children: <Widget>[
        CountryDropDown(),
        UserOffers(),
      ],
    );
  }
}

class CountryDropDown extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return Consumer<SingleSelectCountry>(
      builder: (
          final BuildContext context,
          final SingleSelectCountry singleSelectCountry,
          final Widget child,
          ) {
        return DropdownButton<String>(
          hint: const Text("Not selected"),
          icon: const Icon(Icons.flight),
          value: singleSelectCountry.selected,
          onChanged: (final String newValue) {
            singleSelectCountry.selected = newValue;
          },
          items: singleSelectCountry.items.map<DropdownMenuItem<String>>(
                (final String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            },
          ).toList(),
        );
      },
    );
  }
}

class UserOffers extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return Consumer<SingleSelectCountry>(
      builder: (
          final BuildContext context,
          final SingleSelectCountry singleSelectCountry,
          final Widget child,
          ) {
        return Text(singleSelectCountry.selected ?? '');
      },
    );
  }
}

















//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:shoptempdb/providers/orders.dart';
//import 'package:shoptempdb/widgets/app_drawer.dart';
//import 'package:shoptempdb/widgets/order_item.dart';
//
//
//class TestScreen extends StatefulWidget {
//
//  static const routeName = '/test';
//
//  @override
//  _TestScreenState createState() => _TestScreenState();
//}
//
//class _TestScreenState extends State<TestScreen>{
//
////  var _showList = false;
////  var _isInit = true;
////  var _isLoading = false;
////
////  @override
////  void didChangeDependencies(){
////    if(_isInit) {
////      setState(() {
////        _isLoading = true;
////      });
////      Provider.of<Orders>(context).fetchAndSetOrders().then((_){
////        setState(() {
////          _isLoading = false;
////        });
////      });
////    }
////    _isInit = false;
////    super.didChangeDependencies();
////  }
//
//  @override
//  Widget build(BuildContext context) {
////    final orderData = Provider.of<Orders>(context);
//
//    return Scaffold(
//      appBar: AppBar(title: Text('Test Screen'),),
//      drawer: AppDrawer(),
//      body:
//
////      _isLoading?Center(child:CircularProgressIndicator()):Column(
////        children: <Widget>[
////          orderData.orders.length > 0 ? Container(
////                child:ListView.builder(
////                  itemCount: orderData.orders.length,
////                  itemBuilder: (context, i) =>
////                      OrderItemWidget(orderData.orders[i]),
////                ),
////              ):Container(child: Center(child: Text('No previous orders'),),),
////        ],
////      )
//
//      FutureBuilder(
//        future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(),
//          builder: (context,dataSnapshot) {
//            if(dataSnapshot.connectionState == ConnectionState.waiting) {
//              return Center(child: CircularProgressIndicator(),);
//            }else{
//              if(dataSnapshot.error != null){
//                return Center(child: Text('error occurred'),);
//              }else{
//                return Consumer<Orders>(builder: (context,data,child) => ListView.builder(
//                  itemCount: data.orders.length,
//                  itemBuilder: (context,i) => Text(data.orders[i].invoiceAmount.toString()),
//                ),);
//              }
//            }
//          }
//      ),
//    );
//  }
//
//}