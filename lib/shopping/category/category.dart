import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../../services/api.dart';
import '../../../services/size_config.dart';
import '../../../widget/customWidget.dart';
import '../../../widget/theme.dart';

class Category extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List categoryList = [];
  List subCategory = [];

  Future? category;

  Map? selectedIndex;
  var width;

  Future<Map> getCategory() {
    return Api.http.get("shopping/category").then((response) {
      setState(() {
        categoryList = response.data['list'];
        subCategory = response.data['list'][0]['subCategory'];
        selectedIndex = categoryList[0];
      });

      return response.data;
    });
  }

  @override
  void initState() {
    category = getCategory();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: text(
          'Categories'.toUpperCase(),
          fontweight: FontWeight.bold,
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
          buildMLMCart(context),
        ],
      ),
      body: FutureBuilder(
        future: category,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }

          return categoryList.length > 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: buildCategoryList(),
                    ),
                    Expanded(
                      flex: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        decoration: boxDecoration(
                          showShadow: false,
                          bgColor: white,
                        ),
                        child: Column(
                          children: [
                            if (selectedIndex != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: text(
                                    selectedIndex!['name'],
                                    fontFamily: fontSemibold,
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: Container(
                                height: h(99),
                                child: buildSubcategoryList(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : Center(
                  child: emptyWidget(
                    context,
                    'assets/images/no_result.png',
                    "No Data Found in Category List",
                    "There was no record based on the details you entered.",
                  ),
                );
        },
      ),
    );
  }

  Widget buildCategoryList() {
    return ListView.builder(
      itemCount: categoryList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              subCategory = categoryList[index]['subCategory'];
              selectedIndex = categoryList[index];
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedIndex == categoryList[index] ? Colors.white : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: CachedNetworkImage(
                    imageUrl: categoryList[index]['url'],
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                    fit: BoxFit.cover,
                    height: width * 0.18,
                    width: width * 0.18,
                  ),
                ),
                SizedBox(height: 8.0),
                text(
                  categoryList[index]['name'],
                  isCentered: true,
                  isLongText: true,
                  fontSize: 13.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSubcategoryList(BuildContext context) {
    return subCategory.length > 0
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 135,
            ),
            padding: EdgeInsets.only(right: 10),
            shrinkWrap: true,
            itemCount: subCategory.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed("/product-list", arguments: {
                    "category": [subCategory[index]['id']],
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 5.h,
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.r),
                        child: CachedNetworkImage(
                          imageUrl: subCategory[index]['url'],
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                            width: 100.sp,
                            height: 100.sp,
                          ),
                          fit: BoxFit.cover,
                          height: width * 0.20,
                          width: width * 0.20,
                        ),
                      ),
                      // SizedBox(height: 8.0),
                      Expanded(
                        child: text(
                          subCategory[index]['name'],
                          isCentered: true,
                          maxLine: 2,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : Center(
            child: Image.asset('assets/images/results.png'),
          );
  }
}
