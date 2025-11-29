import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/api.dart';
import '../../../services/validator_x.dart';
import '../../../utils/app_utils.dart';
import '../../../widget/theme.dart';
import '../../services/auth.dart';

class ReviewAdd extends StatefulWidget {
  const ReviewAdd({Key? key}) : super(key: key);

  @override
  _ReviewAddState createState() => _ReviewAddState();
}

class _ReviewAddState extends State<ReviewAdd> {
  num rating = 5;
  final TextEditingController _commentController = TextEditingController();

  final _addReviewFormKey = GlobalKey<FormState>();
  Map? product;

  ValidatorX validator = ValidatorX();

  bool submit = false;

  @override
  void initState() {
    product = Get.arguments;
    if (product!['product']["review"] != null) {
      rating = product!['product']["review"]["rating"];
      _commentController.text = product!['product']["review"]["review"];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text(
          product!['editType'] ? 'Edit Review' : 'Add Review',
          textColor: Colors.black,
        ),
      ),
      body: review(),
    );
  }

  Widget review() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _addReviewFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: RatingBar(
                    itemSize: 45,
                    initialRating: rating.toDouble(),
                    glowColor: Colors.transparent,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.star,
                          size: 5.sp,
                          color: Colors.orange,
                        ),
                        half: Icon(
                          Icons.star,
                          size: 5.sp,
                          color: Colors.orange,
                        ),
                        empty: Icon(
                          Icons.star_border,
                          size: 5.sp,
                          color: gray,
                        )),
                    onRatingUpdate: (value) {
                      setState(() {
                        rating = value;
                      });
                    }),
                // SmoothStarRating(
                //   rating: rating.toDouble(),
                //   isReadOnly: false,
                //   size: 45,
                //   filledIconData: Icons.star,
                //   // halfFilledIconData: Icons.star_half,
                //   defaultIconData: Icons.star_border,
                //   allowHalfRating: false,
                //   starCount: 5,
                //   spacing: 2.0,
                //   onRated: (value) {
                //     setState(() {
                //       rating = value;
                //     });
                //   },
                // ),
              ),
              SizedBox(height: 10),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ,-]'))],
                controller: _commentController,
                maxLines: 6,
                validator: validator.add(
                  key: 'review',
                  rules: [
                    ValidatorX.mandatory(),
                  ],
                ),
                onChanged: (value) {
                  validator.clearErrorsAt('review');
                },
                decoration: InputDecoration(
                  hintText: ('Your thoughts.....'),
                  border: OutlineInputBorder(),
                  // fillColor: Colors.red,
                ),
              ),
              SizedBox(height: 12),
              submit != true
                  ? CustomButton(
                      textContent: product!['editType'] ? 'Update' : 'Submit',
                      onPressed: () {
                        if (_addReviewFormKey.currentState!.validate()) {
                          submit = true;
                          FocusScope.of(context).requestFocus(FocusNode());
                          Map sendData = {
                            "product_id": product!['product']['id'],
                            'rating': rating,
                            'review': _commentController.text,
                            "user_type": Auth.check()! ? 1 : 2,
                          };

                          if (rating > 0) {
                            Api.http
                                .post(
                                    product!['editType']
                                        ? 'shopping/review/update'
                                        : 'shopping/review/store',
                                    data: sendData)
                                .then((response) {
                              GetBar(
                                backgroundColor:
                                    response.data['status'] ? Colors.green : Colors.red,
                                duration: Duration(seconds: 3),
                                message: response.data['message'],
                              ).show();

                              if (response.data['status']) {
                                Timer(
                                  Duration(seconds: 3),
                                  () {
                                    Get.back();
                                  },
                                );
                              } else {
                                setState(() {
                                  submit = false;
                                });
                              }
                            }).catchError(
                              (error) {
                                setState(() {
                                  submit = false;
                                });
                                if (error.response.statusCode == 422) {
                                  validator.setErrors(error.response.data['errors']);
                                }
                              },
                            );
                          } else {
                            AppUtils.showErrorSnackBar("Select Rating");
                          }
                        }
                      },
                    )
                  : Center(),
            ],
          ),
        ),
      ),
    );
  }
}
