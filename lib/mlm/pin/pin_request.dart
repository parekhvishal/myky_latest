import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/getImage_service.dart';
import '../../services/validator_x.dart';
import '../../widget/image_picker.dart';
import '../../widget/theme.dart';

class PinRequest extends StatefulWidget {
  @override
  _PinRequestState createState() => _PinRequestState();
}

class _PinRequestState extends State<PinRequest> {
  File? _image;
  Map? balance;
  Future getImage(ImgSource source) async {
    PickedFile? image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
    );
    setState(() {
      _image = File(image!.path);
    });
  }

  bool isSubmit = false;

  bool uploading = false;
  String progressString = "";

  TimeOfDay? time;
  DateTime date = DateTime(1900);
  ValidatorX validator = ValidatorX();
  String? myBankSelection;
  String? myPackageSelection;
  String? myPaymentSelection;
  final _pinFormKey = GlobalKey<FormState>();

  Map? pinData;
  Map<String, dynamic>? _errors;
  bool uploadingImage = false;
  final format = DateFormat("HH:mm");

  TextEditingController _pinQtyController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _depositDateController = TextEditingController();
  TextEditingController _depositTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPinData();
  }

  void getPinData() async {
    Api.http.get('member/pin-requests/create').then((response) {
      setState(() {
        pinData = response.data;
      });
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Pin Request')),
      body: SingleChildScrollView(
        child: Form(
          key: _pinFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            setState(() {
              _errors = {};
            });
          },
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
                      'Select package with pin quantity',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    SizedBox(height: 10),
                    if (pinData != null)
                      DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true,
                        validator: validator.add(
                          key: 'package_id',
                          rules: [
                            ValidatorX.mandatory(message: "Select Your Package"),
                          ],
                        ),
                        hint: text(
                          'Select Package',
                          fontSize: textSizeMedium,
                          textColor: textColorPrimary.withOpacity(0.7),
                          fontFamily: fontMedium,
                        ),
                        value: myPackageSelection,
                        decoration: InputDecoration(
                          border:
                              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                        ),
                        onChanged: (String? newValue) {
                          validator.clearErrorsAt('package_id');
                          setState(() {
                            myPackageSelection = newValue;
                          });
                        },
                        items: pinData!['packages'].map<DropdownMenuItem<String>>((packages) {
                          return DropdownMenuItem<String>(
                            value: packages['id'].toString(),
                            child:
                                Text(packages['name'].toString() + " (" + packages['amount'] + ")"),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 15),
                    floatingInput(
                      'Pin Quantity',
                      controller: _pinQtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[- .,0]'))],
                      validator: validator.add(
                        key: 'no_pins',
                        rules: [
                          ValidatorX.mandatory(message: "Pin Quantity field is required"),
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt("no_pins");
                      },
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
                      'Select Banking Details',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    SizedBox(height: 10),
                    if (pinData != null)
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
                            myPaymentSelection = newValue;
                          });
                        },
                        items: pinData!['paymentMode'].map<DropdownMenuItem<String>>((paymentMode) {
                          return DropdownMenuItem<String>(
                            value: paymentMode['id'].toString(),
                            child: Text(paymentMode['name']),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 15),
                    floatingInput(
                      'Reference Number',
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ]|[,. -]'))],
                      controller: _referenceController,
                      validator: validator.add(
                        key: 'bank_name',
                        rules: [
                          ValidatorX.mandatory(message: "Reference number field is required"),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    if (pinData != null)
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
                            myBankSelection = newValue;
                          });
                        },
                        items: pinData!['bankDetails'].map<DropdownMenuItem<String>>((bank) {
                          return DropdownMenuItem<String>(
                            value: bank['id'].toString(),
                            child: Text(
                              bank['name'].toString(),
                            ),
                          );
                        }).toList(),
                      ),
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
              isSubmit != true
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomButton(
                        textContent: 'Submit',
                        onPressed: () async {
                          if (_pinFormKey.currentState!.validate()) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            isSubmit = true;
                            dynamic profileImage;
                            if (_image != null) {
                              profileImage = await Vapor.upload(
                                _image,
                                progressCallback: (int? completed, int? total) {
                                  setState(() {
                                    uploading = true;
                                    progressString =
                                        ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                  });
                                },
                              );
                            }
                            setState(() {
                              uploading = false;
                            });
                            Map sendData = {
                              'payment_mode': myPaymentSelection,
                              'reference_no': _referenceController.text,
                              'bank_name': myBankSelection,
                              'date': _depositDateController.text,
                              'time': _depositTimeController.text,
                              'receipt': profileImage,
                              'no_pins': _pinQtyController.text,
                              'package_id': myPackageSelection,
                            };
                            Api.http.post('member/pin-requests', data: sendData).then((res) async {
                              if (res.data['status']) {
                                GetBar(
                                  duration: Duration(seconds: 3),
                                  message: res.data['message'],
                                  backgroundColor: Colors.green,
                                ).show();
                                Timer(
                                  Duration(seconds: 3),
                                  () {
                                    Get.back(result: res.data);
                                  },
                                );
                              } else {
                                GetBar(
                                  duration: Duration(seconds: 5),
                                  message: res.data['error'],
                                  backgroundColor: Colors.red,
                                ).show();
                              }
                            }).catchError((error) {
                              if (error.response.statusCode == 401 ||
                                  error.response.statusCode == 403) {
                                GetBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 5),
                                  message: error.response.data['message'],
                                ).show();
                              }
                              if (error.response.statusCode == 422) {
                                setState(() {
                                  validator.setErrors(error.response.data['errors']);
                                  _errors = error.response.data['errors'];
                                });
                              }
                            });
                          }
                        },
                      ),
                    )
                  : SizedBox.shrink(),
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
            'Upload Deposit Image',
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
                                'assets/images/placeholder.png',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                      if (uploading)
                        Container(
                          height: 200.0,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 20.0),
                              Text(
                                "Uploading Image: $progressString",
                              )
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
          if (_errors != null && _image == null && _errors!.containsKey('receipt'))
            SizedBox(height: 5),
          if (_errors != null && _image == null && _errors!.containsKey('receipt'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errors!['receipt'][0],
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
