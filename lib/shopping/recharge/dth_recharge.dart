import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../shopping/recharge/dthPlanScreen.dart';
import '../../utils/app_utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../services/api.dart';
import '../../../services/validator_x.dart';
import '../../../widget/theme.dart';

class DthRecharge extends StatefulWidget {
  @override
  _DthRechargeState createState() => _DthRechargeState();
}

class _DthRechargeState extends State<DthRecharge> {
  int operatorType = 4;

  final _dthFormKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionPasswordController = TextEditingController();

  ValidatorX validator = ValidatorX();
  var operatorSelection;
  int? orderId;

  List dthOperator = [];

  bool passwordVisible = false;

  @override
  void initState() {
    dthOperator = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('DTH Recharge'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _dthFormKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                _buildRegisterNumberField(context),
                SizedBox(height: 20),
                if (dthOperator.length > 0) ...[
                  _buildOperatorField(context),
                  SizedBox(height: 20),
                  text(
                    'View Plans',
                    textColor: blue,
                    fontFamily: fontBold,
                    decoration: TextDecoration.underline,
                  ).onTap(() {
                    if (operatorSelection != null) {
                      AppUtils.fetchPlans(code: operatorSelection['code']).then((value) {
                        if (value.runtimeType == String) {
                          AppUtils.showErrorSnackBar(value);
                        } else {
                          Get.to(DTHPlanScreen(value))!.then((value) {
                            if (value != null) {
                              setState(() {
                                _amountController.text = value['recharge_amount'].toString();
                              });
                            }
                          });
                        }
                      });
                    } else {
                      AppUtils.showErrorSnackBar('Please select Operator to view Plans');
                    }
                  }),
                  20.height,
                ],
                _buildAmountField(context),
                SizedBox(height: 30),
                // _buildTransactionPasswordField(context),
                // SizedBox(height: 30),
                _buildButtonField(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorField(BuildContext context) {
    return DropdownButtonFormField<Map>(
      isDense: true,
      isExpanded: true,
      validator: (value) {
        if (value == null) {
          return 'Operator is required';
        }
      },
      // validator: validator.add(
      //   key: 'operator_id',
      //   rules: [
      //     ValidatorX.mandatory(message: "Select your operator"),
      //   ],
      // ),
      hint: text('Select your operator', fontFamily: fontMedium, textColor: grey),
      decoration: InputDecoration(border: OutlineInputBorder()),
      value: operatorSelection,
      iconSize: 20,
      elevation: 16,
      onChanged: (Map? newValue) {
        validator.clearErrorsAt('operator_id');
        setState(() {
          operatorSelection = newValue!;
        });
      },
      items: dthOperator.map<DropdownMenuItem<Map>>((category) {
        return DropdownMenuItem<Map>(
          value: category,
          child: text(
            category['name'].toString(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRegisterNumberField(BuildContext context) {
    return TextFormField(
      validator: validator.add(
        key: 'phone',
        rules: [
          ValidatorX.mandatory(message: "Registered Mobile No./ Subscriber ID Number can't be empty"),
        ],
      ),
      controller: _cardNumberController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Registered Mobile No./ Subscriber ID',
      ),
      style: primaryTextStyle(
        fontFamily: fontMedium,
      ),
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return TextFormField(
      validator: validator.add(
        key: 'amount',
        rules: [
          ValidatorX.mandatory(message: "Amount is required"),
        ],
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ,-]'))],
      maxLength: 4,
      readOnly: true,
      controller: _amountController,
      decoration: const InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Amount',
        prefixText: ' ₹ ',
      ),
      style: primaryTextStyle(
        fontFamily: fontMedium,
      ),
    );
  }

  Widget _buildTransactionPasswordField(BuildContext context) {
    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r'[ ,.-]'))],
      validator: validator.add(
        key: 'financial_password',
        rules: [
          ValidatorX.mandatory(message: "Transaction Password is required"),
        ],
      ),
      controller: _transactionPasswordController,
      obscureText: passwordVisible,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Transaction Password',
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
          child: passwordVisible ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
        ),
      ),
      style: primaryTextStyle(
        fontFamily: fontMedium,
      ),
    );
  }

  Widget _buildButtonField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          textContent: "Proceed".toUpperCase(),
          onPressed: () {
            if (_dthFormKey.currentState!.validate()) {
              FocusScope.of(context).requestFocus(FocusNode());

              Map sendData = {
                'phone': _cardNumberController.text,
                'operator_id': operatorSelection['id'],
                'amount': _amountController.text,
                // 'financial_password': _transactionPasswordController.text,
              };

              Api.http.post('member/recharge/dth-recharge', data: sendData).then((response) {
                if (response.data['status']) {
                  orderId = response.data['rechargeOrder']['id'];
                  Get.toNamed(
                    '/payment-web-view',
                    arguments: response.data['webPaymentUrl'],
                  )?.then((value) {
                    if (value != null) {
                      Get.toNamed('/recharge-thanks', arguments: orderId);
                    }
                  });
                  // AppUtils.startTransaction(response.data);
                } else {
                  AppUtils.showErrorSnackBar(response.data['message']);
                }
              }).catchError(
                (error) {
                  if (error.response.statusCode == 422) {
                    setState(() {
                      validator.setErrors(error.response.data['errors']);
                    });
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
