import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/productCategories.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';


class TestScreen extends StatelessWidget {

  static const routeName = '/test';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category'),),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<ProductCategories>(context,listen: false).fetchProductsCategory(),
          builder: (context,dataSnapshot) {
            if(dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(),);
            }else{
              if(dataSnapshot.error != null){
                return Center(child: Text('error occurred'),);
              }else{
                return Consumer<ProductCategories>(builder: (context,catData,child) => ListView.builder(
                  itemCount: catData.getCategories.length,
                  itemBuilder: (context,i) => Text(catData.getCategories[i].name),
                ),);
              }
            }
          }
      ),
    );
  }

}