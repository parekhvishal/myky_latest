import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/api.dart';
import '../../../../services/size_config.dart';
import '../../../../widget/network_image.dart';
import '../../../../widget/theme.dart';
import '../../services/extension.dart';

class BestSellerPage extends StatefulWidget {
  const BestSellerPage({Key? key}) : super(key: key);

  @override
  _BestSellerPageState createState() => _BestSellerPageState();
}

class _BestSellerPageState extends State<BestSellerPage> {
  late Map bestSellerIdList;
  Future? bestSellerFuture;

  @override
  void initState() {
    bestSellerIdList = Get.arguments;
    bestSellerFuture = getBestSeller();
    super.initState();
  }

  List bestSellerDataList = [];

  Future<Map> getBestSeller() {
    return Api.http.get("shopping/best-seller").then((response) {
      return response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Best Seller'),
      ),
      body: FutureBuilder(
        future: bestSellerFuture,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }
          bestSellerDataList = snapshot.data!['list'];
          return Column(
            children: [
              SizedBox(
                height: h(80.0),
                child: GridView.builder(
                  itemCount: bestSellerDataList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: h(15.0),
                              width: w(40.0),
                              decoration: BoxDecoration(
                                // color: Colors.pink.shade100,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: bestSellerDataList[index]['url'] != null
                                  ? PNetworkImage(
                                      bestSellerDataList[index]['url'],
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      'assets/images/no_image.png',
                                      fit: BoxFit.contain,
                                    ),
                            ).onClick(() {
                              Get.toNamed("/product-list", arguments: {
                                "category": [bestSellerDataList[index]['id']],
                              });
                            }),
                            SizedBox(height: 10.0),
                            text(bestSellerDataList[index]['categoryName']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
