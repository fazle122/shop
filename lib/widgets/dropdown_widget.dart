import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/shipping_address.dart';



class DropdownWidget extends StatefulWidget {
  final IconData icon;
  final Map<String,dynamic> items;
  final ValueChanged<String> itemCallBack;
  final String currentItem;
  final String errorMessage;
  final String hintText;

  DropdownWidget({
    this.icon,
    this.items,
    this.itemCallBack,
    this.currentItem,
    this.errorMessage,
    this.hintText,
  });

  @override
  State<StatefulWidget> createState() => _DropdownState(currentItem);
}

class _DropdownState extends State<DropdownWidget> {
  List<DropdownMenuItem<String>> dropDownItems = [];
  String currentItem;

  _DropdownState(this.currentItem);


  @override
  void initState() {
    super.initState();
    widget.items.forEach((key, value) {
      dropDownItems.add(DropdownMenuItem(
        value: value,
        child: Text(value),
      ));
    });
  }


  @override
  void didUpdateWidget(DropdownWidget oldWidget) {
    if (this.currentItem != widget.currentItem) {
      setState(() {
        this.currentItem = widget.currentItem;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_city,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(),
          ),
          hint: Text(widget.hintText),
          value: currentItem,
          onSaved: (value){
            currentItem = value;
          },
          validator: (value){
            if (value == null) {
              return widget.errorMessage;
            }
            return null;
          },
          onChanged: (newValue) {
            currentItem = newValue;
            widget.itemCallBack(currentItem);
          },
          items: dropDownItems,
        );
      },
    );
  }
}