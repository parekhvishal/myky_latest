import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myky_clone/utils/app_utils.dart';
import 'package:unicons/unicons.dart';

import '../../../services/api.dart';
import '../../../widget/customWidget.dart';
import '../../../widget/network_image.dart';
import '../../../widget/paginated_list.dart';
import '../../../widget/theme.dart';
import '../../services/auth.dart';

class WishList extends StatefulWidget {
  @override
  _WishListState createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  final GlobalKey<PaginatedListState> _wishListPaginatedListKey = GlobalKey();
  Map? productData;
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      key: _wishListPaginatedListKey,
      appBarAction: [
        IconButton(
          constraints: BoxConstraints(maxWidth: 35),
          onPressed: () {
            Get.toNamed('/search-page');
          },
          icon: Icon(UniconsLine.search),
        ),
        SizedBox(width: 10.0),
        buildMLMCart(context),
      ],
      resetStateOnRefresh: true,
      pageTitle: 'Wishlist',
      apiFuture: (int page) async {
        return Api.http.get("shopping/wishlist?page=$page", queryParameters: {
          "user_type": Auth.check()! ? 1 : 2,
        });
      },
      listItemBuilder: _wishListBuilder,
    );
  }

  Widget _wishListBuilder(dynamic data, int index) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/product-detail', arguments: {"type": "wishlist", "data": data});
      },
      child: Container(
        decoration: boxDecoration(
          radius: 0,
          showShadow: false,
        ),
        margin: EdgeInsets.symmetric(vertical: 5),
        height: 140,
        child: Row(
          children: <Widget>[
            Container(
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  data['url'] != null
                      ? PNetworkImage(
                          data['url'],
                          fit: BoxFit.fitHeight,
                        )
                      : Image.asset('assets/images/no_image.png'),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: text(
                            data['name'],
                            overflow: TextOverflow.ellipsis,
                            maxLine: 2,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                title: Text(
                                  'Are you sure you want to remove this item from the WishList?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'No',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        Api.httpWithoutLoader.delete(
                                            'shopping/wishlist/delete/${data['productId']}',
                                            queryParameters: {
                                              "user_type": Auth.check()! ? 1 : 2,
                                            }).then((response) {
                                          Get.back();
                                          _wishListPaginatedListKey.currentState!.refresh();

                                          AppUtils.showSuccessSnackBar(response.data['message']);
                                        }).catchError((err) {});
                                      });
                                    },
                                    child: Text(
                                      'Yes',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            UniconsLine.trash_alt,
                            color: red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        text(
                          '₹ ${data['dp']}',
                          fontFamily: fontMedium,
                          textColor: colorPrimary,
                        ),
                        SizedBox(width: 10),
                        text(
                          ' ₹ ${data['mrp']}',
                          fontSize: 13.0,
                          fontFamily: fontMedium,
                          decoration: TextDecoration.lineThrough,
                          textColor: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
            )
          ],
        ),
      ),
    );
  }
}
