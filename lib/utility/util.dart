import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/products.dart';


class Util{


  static List<DropdownMenuItem> districtMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: value,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  static List<DropdownMenuItem> areaMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  static getDeliveryCharge(BuildContext context,Cart cart) async{
    List deliveryChargeMatrix = [];
    await Provider.of<Products>(context,listen: false).fetchDeliveryCharMatrix().then((data){
      deliveryChargeMatrix = data['range'];
      for(int i=0;i<deliveryChargeMatrix.length;i++){
        if(i == 0 && cart.totalAmount<=deliveryChargeMatrix[i]['max']){
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
        }else if( i>0 && cart.totalAmount >= deliveryChargeMatrix[i]['min']){
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
        }else if( i>0){
            cart.maxDeliveryRange = deliveryChargeMatrix[i]['min'].toDouble();
        }
      }
    });
  }
}