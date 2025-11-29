import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';

class BankDetails extends StatefulWidget {
  const BankDetails({Key? key}) : super(key: key);

  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
  final _kycFormKey = GlobalKey<FormState>();

  String? accountType;
  Map? bankData;

  List _accountTypes = [
    {"type": "Saving", "value": 1},
    {"type": "Current", "value": 2},
  ];

  ValidatorX validator = ValidatorX();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _bankNameController = TextEditingController();
  TextEditingController _bankBranchController = TextEditingController();
  TextEditingController _ifscCodeController = TextEditingController();
  @override
  void initState() {
    getKyc();
    super.initState();
  }

  getKyc() {
    Api.http.get("shopping/guest/bank-detail").then((response) {
      if (response.data['status'] == true) {
        setState(() {
          bankData = response.data;
          if (bankData! != true) {
            _accountNameController.text = bankData!['accountName'];
            _accountNumberController.text = bankData!['accountNumber'];
            _ifscCodeController.text = bankData!['bankIfsc'];
            _bankNameController.text = bankData!['bankName'];
            _bankBranchController.text = bankData!['bankBranch'];
            accountType = bankData!['accountType'];
          }
        });
      }
    });
  }

  Widget accountTypeDropdown() {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      validator: validator.add(
        key: 'account_type',
        rules: [
          ValidatorX.mandatory(message: "Select Your Account Type"),
        ],
      ),
      hint: Text('Select Account Type'),
      value: accountType,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15),
        filled: true,
        fillColor: Color(0xFFf7f7f7),
        hintText: 'Select',
        hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.grey[300]),
      ),
      onChanged: (String? newValue) {
        setState(() {
          accountType = newValue!;
        });
        validator.clearErrorsAt('accountType');
      },
      items: _accountTypes.map<DropdownMenuItem<String>>((type) {
        return DropdownMenuItem<String>(
          child: Text(type['type']),
          value: type['value'].toString(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('Bank Details'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Form(
              key: _kycFormKey,
              autovalidateMode: autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      floatingInput(
                        'Account Holder Name',
                        controller: _accountNameController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
                        validator: validator.add(
                          key: 'accountName',
                          rules: [
                            ValidatorX.mandatory(message: 'Account holder name field is required'),
                          ],
                        ),
                        onChanged: (String value) {
                          validator.clearErrorsAt('accountName');
                        },
                      ),
                      10.height,
                      floatingInput(
                        'Account Number',
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 18,
                        validator: validator.add(
                          key: 'accountNumber',
                          rules: [
                            ValidatorX.mandatory(message: 'Account number field is required'),
                            ValidatorX.minLength(length: 9, message: 'The account number must be between 9 and 18 digits')
                          ],
                        ),
                        onChanged: (String value) {
                          validator.clearErrorsAt('accountNumber');
                        },
                      ),
                      15.height,
                      DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true,
                        validator: validator.add(
                          key: 'accountType',
                          rules: [
                            ValidatorX.mandatory(message: "Select your account type"),
                          ],
                        ),
                        hint: Text('Select Account Type'),
                        value: accountType,
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle: primaryTextStyle(
                            size: 16,
                            color: textColorPrimary.withOpacity(0.7),
                            fontFamily: fontMedium,
                          ),
                          // prefixIcon: prefixIcon,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        ),
                        onChanged: (String? newValue) {
                          validator.clearErrorsAt('accountType');
                          setState(() {
                            accountType = newValue!;
                          });
                        },
                        items: _accountTypes.map<DropdownMenuItem<String>>((type) {
                          return DropdownMenuItem<String>(
                            child: Text(type['type']),
                            value: type['value'].toString(),
                          );
                        }).toList(),
                      ),
                      10.height,
                      floatingInput(
                        'IFSC Code',
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ,-]'))],
                        controller: _ifscCodeController,
                        onChanged: (value) {
                          validator.clearErrorsAt('bankIfsc');
                          if (value.length == 11) {
                            Api.httpWithoutBaseUrl.get('https://ifsc.razorpay.com/' + _ifscCodeController.text).then((res) {
                              setState(() {
                                _bankNameController.text = res.data['BANK'];
                                _bankBranchController.text = res.data['BRANCH'];
                              });
                            }).catchError((err) {
                              AppUtils.showErrorSnackBar('The IFSC code is invalid');

                              setState(() {
                                _bankNameController.text = '';
                                _bankBranchController.text = '';
                              });
                            });
                          } else {
                            setState(() {
                              _bankNameController.text = '';
                              _bankBranchController.text = '';
                            });
                          }
                        },
                        validator: validator.add(
                          key: 'bankIfsc',
                          rules: [
                            ValidatorX.mandatory(message: 'IFSC code is required'),
                          ],
                        ),
                      ),
                      10.height,
                      floatingInput(
                        'Bank Name',
                        controller: _bankNameController,
                        validator: validator.add(
                          key: 'bankName',
                          rules: [
                            ValidatorX.mandatory(message: 'Bank name field is required'),
                          ],
                        ),
                        onChanged: (String value) {
                          validator.clearErrorsAt('bankName');
                        },
                      ),
                      10.height,
                      floatingInput(
                        'Bank Branch',
                        controller: _bankBranchController,
                        validator: validator.add(
                          key: 'bankBranch',
                          rules: [
                            ValidatorX.mandatory(message: 'Bank branch field is required'),
                          ],
                        ),
                        onChanged: (String value) {
                          validator.clearErrorsAt('bankBranch');
                        },
                      ),
                      10.height,
                    ],
                  ),
                  20.height,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      textContent: 'Submit',
                      onPressed: () async {
                        if (_kycFormKey.currentState!.validate()) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            autovalidateMode = AutovalidateMode.onUserInteraction;
                          });
                          Map sendData = {
                            'bankName': _bankNameController.text,
                            'bankBranch': _bankBranchController.text,
                            'bankIfsc': _ifscCodeController.text,
                            'accountType': accountType,
                            'accountName': _accountNameController.text,
                            'accountNumber': _accountNumberController.text,
                          };
                          Api.http.post('shopping/guest/bank-detail', data: sendData).then((response) async {
                            if (response.data['status']) {
                              Get.back();
                              AppUtils.showSuccessSnackBar(response.data['message']);
                            } else {
                              AppUtils.showErrorSnackBar(response.data['message']);
                            }
                          }).catchError((error) {
                            if (error.response.statusCode == 401 || error.response.statusCode == 403) {
                              AppUtils.showErrorSnackBar(error.response.data['message']);
                            }
                            if (error.response.statusCode == 422) {
                              setState(() {
                                validator.setErrors(error.response.data['errors']);
                              });
                            }
                          });
                        }
                      },
                    ),
                  ),
                  10.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
