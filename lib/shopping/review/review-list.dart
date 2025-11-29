import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth.dart';
import '../../widget/network_image.dart';

import '../../services/api.dart';
import '../../widget/theme.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({Key? key}) : super(key: key);

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  int? productId;

  Future? reviewFuture;
  List reviewList = [];

  void initState() {
    productId = Get.arguments;

    reviewFuture = getReview();
    super.initState();
  }

  Future getReview() async {
    Api.http.get("shopping/review/$productId", queryParameters: {
      "user_type": Auth.check()!
          ? 1
          : Auth.isGuest()!
              ? 2
              : null
    }).then((response) {
      if (response.data['status']) {
        setState(() {
          reviewList = response.data!['message'];
        });
      }
      return response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text(
          'Review Details',
          textColor: Colors.black,
        ),
      ),
      body: FutureBuilder(
        future: reviewFuture,
        builder: (context, AsyncSnapshot? snapshot) {
          if (snapshot!.hasData) {
            return Center();
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: reviewList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 18.0,
                                child: PNetworkImage(
                                  reviewList[index]['profileImage'],
                                )),
                            SizedBox(width: 20.0),
                            text(
                              reviewList[index]['name'],
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  text(
                                    reviewList[index]['rating'].toString(),
                                    textColor: Colors.white,
                                    fontweight: FontWeight.w600,
                                    fontSize: 18.0,
                                  ),
                                  SizedBox(width: 5.0),
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: colorPrimary,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 15.0),
                            ),
                            SizedBox(width: 20.0),
                            Expanded(
                              child: text(
                                reviewList[index]['review'],
                                isLongText: true,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
