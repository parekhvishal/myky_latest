import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../../widget/customWidget.dart';
import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/theme.dart';

class TrendingList extends StatefulWidget {
  const TrendingList({Key? key}) : super(key: key);

  @override
  _TrendingListState createState() => _TrendingListState();
}

class _TrendingListState extends State<TrendingList> {
  Map? trendingData;

  List? trendingList = [];

  Future? trending;

  Future<Map> getTrendingCategory(trendingId) {
    return Api.http.get("shopping/trending/$trendingId").then((response) {
      setState(() {
        trendingList = response.data['list'];
      });

      return response.data;
    });
  }

  @override
  void initState() {
    setState(() {
      trendingData = Get.arguments;
    });

    if (trendingData != null) {
      trending = getTrendingCategory(trendingData!['id']);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(
          trendingData!['name'],
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
        future: trending,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }
          return trendingList!.length > 0
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: trendingList!.length,
                  itemBuilder: (context, index) {
                    return _buildTrendingItem(index);
                  },
                )
              : Center(
                  child: emptyWidget(
                    context,
                    'assets/images/no_result.png',
                    "No Data Found in ${trendingData!['name']}",
                    "There was no record based on the details you entered.",
                  ),
                );
        },
      ),
    );
  }

  Widget _buildTrendingItem(index) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Get.toNamed("/product-list", arguments: {
          "category": [trendingList![index]['categoryId']],
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
                  imageUrl: trendingList![index]['url'],
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                  fit: BoxFit.fill,
                  height: width * 0.25,
                  width: width * 0.25,
                ),
              ),
            ),
            SizedBox(height: 4),
            Expanded(
              flex: 2,
              child: Text(
                trendingList![index]['categoryName'],
                style: TextStyle(
                  fontSize: s(5),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
