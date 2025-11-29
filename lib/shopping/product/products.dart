import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../../widget/customWidget.dart';
import '../../widget/product_widget.dart';

class ProductListing extends StatefulWidget {
  @override
  ProductListingState createState() => ProductListingState();
}

class ProductListingState extends State<ProductListing> {
  late Map productFilter;
  @override
  void initState() {
    productFilter = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product List'.toUpperCase(),
        ),
        actions: [
          IconButton(
            constraints: BoxConstraints(maxWidth: 35),
            onPressed: () {
              Get.toNamed('/search-page');
            },
            icon: Icon(UniconsLine.search),
          ),
          SizedBox(width: 10.0),
          buildWishList(context),
          SizedBox(width: 10.0),
          buildMLMCart(context).paddingOnly(right: 4),
        ],
      ),
      body: ProductWidget(
        productFilters: productFilter,
      ),
    );
  }
}
