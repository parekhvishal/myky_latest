import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/getImage_service.dart';
import '../../services/validator_x.dart';
import '../../widget/image_picker.dart';
import '../../widget/theme.dart';

class CreateFundRequest extends StatefulWidget {
  @override
  _CreateFundRequestState createState() => _CreateFundRequestState();
}

class _CreateFundRequestState extends State<CreateFundRequest> {
  File? _image;

  bool uploading = false;
  String progressString = "";

  TimeOfDay? time;
  DateTime date = DateTime(1900);
  ValidatorX validator = ValidatorX();
  String? myBankSelection;
  String? myPackageSelection;
  String? myPaymentSelection;
  final _fundFormKey = GlobalKey<FormState>();

  Map? fundData;
  Map<String, dynamic>? _errors;
  bool uploadingImage = false;
  // final format = DateFormat("HH:mm");
  final format = DateFormat("dd-MM-yyyy, HH:mm");

  TextEditingController _amountController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _depositDateController = TextEditingController();
  TextEditingController _depositTimeController = TextEditingController();
  TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getFundData();
  }

  void getFundData() async {
    Api.http.get('member/fund-request/create').then((response) {
      setState(() {
        fundData = response.data;
      });
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 2.0, title: Text('Create Fund Request')),
      body: SingleChildScrollView(
        child: Form(
          key: _fundFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white,
                  radius: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      'Fund Request',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    SizedBox(height: 15),
                    floatingInput(
                      'Amount',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[- .,0]'))],
                      validator: validator.add(
                        key: 'amount',
                        rules: [
                          ValidatorX.mandatory(message: "Amount field is required"),
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt("amount");
                      },
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white,
                  radius: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      'Select Banking Details',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    SizedBox(height: 10),
                    if (fundData != null)
                      DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true,
                        validator: validator.add(
                          key: 'payment_mode',
                          rules: [
                            ValidatorX.mandatory(message: "Select Your Payment Method"),
                          ],
                        ),
                        hint: text(
                          'Select Payment Method',
                          fontSize: textSizeMedium,
                          textColor: textColorPrimary.withOpacity(0.7),
                          fontFamily: fontMedium,
                        ),
                        value: myPaymentSelection,
                        decoration: InputDecoration(
                          border:
                              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                        ),
                        onChanged: (String? newValue) {
                          validator.clearErrorsAt('payment_mode');
                          setState(() {
                            myPaymentSelection = newValue!;
                          });
                        },
                        items:
                            fundData!['paymentMode'].map<DropdownMenuItem<String>>((paymentMode) {
                          return DropdownMenuItem<String>(
                            value: paymentMode['id'].toString(),
                            child: Text(paymentMode['name']),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 15),
                    floatingInput(
                      'Reference Number',
                      controller: _referenceController,
                      keyboardType: TextInputType.text,
                      validator: validator.add(
                        key: 'bank_name',
                        rules: [
                          ValidatorX.mandatory(message: "Reference number field is required"),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    if (fundData != null)
                      DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true,
                        validator: validator.add(
                          key: 'bank_name',
                          rules: [
                            ValidatorX.mandatory(message: "Select Your Bank"),
                          ],
                        ),
                        hint: text(
                          'Select Bank',
                          fontSize: textSizeMedium,
                          textColor: textColorPrimary.withOpacity(0.7),
                          fontFamily: fontMedium,
                        ),
                        value: myBankSelection,
                        decoration: InputDecoration(
                          border:
                              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                        ),
                        onChanged: (String? newValue) {
                          validator.clearErrorsAt('bank_name');
                          setState(() {
                            myBankSelection = newValue!;
                          });
                        },
                        items: fundData!['bankDetails'].map<DropdownMenuItem<String>>((bank) {
                          return DropdownMenuItem<String>(
                            value: bank['id'].toString(),
                            child: Text(
                              bank['name'].toString(),
                            ),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white,
                  radius: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      'Select Deposit Date-Time And Receipt',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    SizedBox(height: 15),
                    floatingInput(
                      'Deposit Date',
                      controller: _depositDateController,
                      validator: validator.add(
                        key: 'date',
                        rules: [
                          ValidatorX.mandatory(message: "Deposit date field is required"),
                        ],
                      ),
                      onChanged: (value) {
                        validator.clearErrorsAt('date');
                      },
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());

                        date = (await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        ))!;
                        if (date != null) {
                          _depositDateController.text = date.toLocal().toString().split(' ')[0];
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    floatingInput(
                      'Deposit Time',
                      controller: _depositTimeController,
                      validator: validator.add(
                        key: 'time',
                        rules: [
                          ValidatorX.mandatory(message: "Deposit time field is required"),
                        ],
                      ),
                      onChanged: (value) {
                        validator.clearErrorsAt('time');
                      },
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());

                        time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            DateTime.now(),
                          ),
                        );
                        if (time != null) {
                          _depositTimeController.text = time!.format(context);
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    depositImage(context),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    textContent: 'Submit',
                    onPressed: () async {
                      if (_fundFormKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        dynamic receiptImage;
                        if (_image != null) {
                          receiptImage = await Vapor.upload(
                            _image!,
                            // progressCallback: (int? completed, int? total) {
                            //   setState(() {
                            //     uploading = true;
                            //     progressString = ((completed / total) * 100)
                            //             .toStringAsFixed(0) +
                            //         "%";
                            //   });
                            // },
                          );
                        }
                        setState(() {
                          uploading = false;
                        });

                        Map bankSendData = {
                          'amount': _amountController.text,
                          'receipt': receiptImage,
                          'paymentMode': myPaymentSelection,
                          'date': _depositDateController.text,
                          'time': _depositTimeController.text,
                          'reference_no': _referenceController.text,
                          'bankName': myBankSelection
                        };

                        Api.http
                            .post('member/fund-request/store', data: bankSendData)
                            .then((res) async {
                          if (res.data['status']) {
                            GetBar(
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                              message: res.data['message'],
                            ).show();
                            setState(() {
                              _codeController.clear();
                              _amountController.clear();
                              _referenceController.clear();
                              _depositTimeController.clear();
                              _depositDateController.clear();
                              myBankSelection = null;
                              myPaymentSelection = null;
                              _image = null;
                            });
                            Timer(
                              Duration(seconds: 3),
                              () {
                                Get.back(result: res.data);
                              },
                            );
                          } else {
                            GetBar(
                              duration: Duration(seconds: 3),
                              message: res.data['error'],
                              backgroundColor: Colors.red,
                            ).show();
                          }
                        }).catchError((errors) {
                          if (errors.response.statusCode == 422) {
                            validator.setErrors(errors.response.data['errors']);
                            GetBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              message: errors.response.data['errors']['image'][0],
                            ).show();
                          }
                        });
                      }
                    },
                  )),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget depositImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload Receipt',
            fontSize: textSizeLargeMedium,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
          ),
          SizedBox(height: 15),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (!uploading)
                        _image != null
                            ? Image.file(
                                _image!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                'assets/images/no_image.png',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                      if (uploading)
                        Container(
                          height: 85.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(progressString),
                              CircularProgressIndicator(),
                            ],
                          ),
                        )
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(spacing_control),
                margin: EdgeInsets.only(top: 15, right: 10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: white, border: Border.all(color: colorPrimary)),
                child: GestureDetector(
                  onTap: () {
                    GetImageFromDevice.instance.getImage(ImgSource.both, context).then((file) {
                      if (file != null) {
                        _image = file;
                        setState(() {});
                      }
                    });
                  },
                  child: Icon(
                    Icons.camera_alt,
                    color: colorPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (_errors != null && _image == null && _errors!.containsKey('image'))
            SizedBox(height: 5),
          if (_errors != null && _image == null && _errors!.containsKey('image'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errors!['image'][0],
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
