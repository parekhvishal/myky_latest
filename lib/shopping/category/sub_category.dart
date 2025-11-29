import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/api.dart';
import '../../../widget/theme.dart';

class SubCategory extends StatefulWidget {
  @override
  _SubCategoryState createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  Map? categoryData;

  List? categoryList;

  List? subCategoryList;

  Future? category;

  Future<Map> getSubCategory(categoryData) {
    return Api.http.get("shopping/category").then((response) {
      setState(() {
        categoryList = response.data['list'];
        categoryList!.map((category) {
          if (category['id'] == categoryData['id']) {
            subCategoryList = category['subCategory'];
          }
        }).toList();
      });

      return response.data;
    });
  }

  @override
  void initState() {
    setState(() {
      categoryData = Get.arguments;
    });

    if (categoryData != null) {
      category = getSubCategory(categoryData);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryData!['name'])),
      body: FutureBuilder(
        future: category,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }
          return subCategoryList!.length > 0
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: subCategoryList!.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryItem(index);
                  },
                )
              : Center(
                  child: emptyWidget(
                    context,
                    'assets/images/no_result.png',
                    "No Data Found in ${categoryData!['name']}",
                    "There was no record based on the details you entered.",
                  ),
                );
        },
      ),
    );
  }

  Widget _buildCategoryItem(index) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Get.toNamed("/product-list", arguments: {
          "category": [subCategoryList![index]['id']],
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: subCategoryList![index]['url'],
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                  fit: BoxFit.fill,
                  height: width * 0.20,
                  width: width * 0.20,
                ),
              ),
            ),
            SizedBox(height: 4),
            Expanded(
              flex: 2,
              child: text(
                subCategoryList![index]['name'],
                overflow: TextOverflow.ellipsis,
                isCentered: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
