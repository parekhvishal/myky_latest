import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';

class CancelRequest extends StatefulWidget {
  @override
  _CancelRequestState createState() => _CancelRequestState();
}

class _CancelRequestState extends State<CancelRequest> {
  final _requestFormKey = GlobalKey<FormState>();
  Map? orderDetail;
  ValidatorX validator = ValidatorX();
  TextEditingController _cancelItemController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    orderDetail = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Name')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _requestFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        text(
                          'Reason For Cancel',
                          isLongText: true,
                          textColor: colorPrimaryDark,
                          fontFamily: fontSemibold,
                          fontSize: textSizeLargeMedium,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Why you want to cancel ?',
                          ),
                          controller: _cancelItemController,
                          maxLines: 1,
                          validator: validator.add(
                            key: 'reason',
                            rules: [
                              ValidatorX.mandatory(message: 'Reason field is required'),
                            ],
                          ),
                          onChanged: (String value) {
                            validator.clearErrorsAt('reason');
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _remarkController,
                          validator: validator.add(
                            key: 'remark',
                            rules: [
                              ValidatorX.mandatory(message: 'Remark field is required'),
                            ],
                          ),
                          onChanged: (String value) {
                            validator.clearErrorsAt('remark');
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Remark',
                          ),
                          maxLines: 4,
                        ),
                        SizedBox(height: 20),
                        _sendButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      //   },
      // ),
    );
  }

  _sendButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: MaterialButton(
        color: colorPrimary,
        padding: EdgeInsets.all(15),
        child: text(
          'Submit',
          textColor: white,
          fontFamily: fontBold,
          textAllCaps: true,
        ),
        onPressed: () {
          if (_requestFormKey.currentState!.validate()) {
            FocusScope.of(context).requestFocus(FocusNode());
            Map requestData = {
              'reason': _cancelItemController.text,
              'remark': _remarkController.text,
              'id': orderDetail!['id'],
              'orderNo': orderDetail!['orderNo'],
            };
            if (_requestFormKey.currentState!.validate())
              Api.http.post('shopping/order/cancel', data: requestData).then(
                (response) async {
                  AppUtils.showInfoSnackBar(
                    response.data['message'],
                    color: response.data['status'] ? Colors.green : Colors.red,
                  );
                  if (response.data['status']) {
                    Timer(Duration(seconds: 3), () {
                      Get.back(result: true);
                    });
                  }
                },
              ).catchError(
                (error) {
                  if (error.response.statusCode == 422) {
                    AppUtils.showErrorSnackBar(error.response.data['message']);
                  } else if (error.response.statusCode == 401) {
                    AppUtils.showErrorSnackBar(error.response.data['message']);
                  }
                },
              );
          }
        },
      ),
    );
  }
}
