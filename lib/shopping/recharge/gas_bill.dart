import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../services/api.dart';
import '../../../../services/validator_x.dart';
import '../../../widget/theme.dart';

class GasBill extends StatefulWidget {
  @override
  _GasBillState createState() => _GasBillState();
}

class _GasBillState extends State<GasBill> {
  final _gasFormKey = GlobalKey<FormState>();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _consumerNumberController = TextEditingController();
  final TextEditingController _customerMobileNumberController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _billNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionPasswordController = TextEditingController();

  ValidatorX validator = ValidatorX();
  String? operatorSelection;

  List gasOperator = [];

  bool passwordVisible = false;

  @override
  void initState() {
    gasOperator = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Gas Bill Payment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          child: Form(
            key: _gasFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                if (gasOperator.length > 0) ...[
                  _buildOperatorField(context),
                  SizedBox(height: 20.0),
                ],
                _buildConsumerNumberField(context),
                SizedBox(height: 20.0),
                _buildAmountField(context),
                SizedBox(height: 20.0),
                // _buildTransactionPasswordField(context),
                // SizedBox(height: 20.0),
                _buildButtonField(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField(BuildContext context) {
    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r'[ ,.-]'))],
      validator: validator.add(
        key: 'mobile',
        rules: [
          ValidatorX.custom((value, {key}) {
            String pattern = r'[6789][0-9]{9}$';
            RegExp regExp = new RegExp(pattern);
            if (value!.length == 0) {
              return "Mobile is Required";
            } else if (value.length != 10) {
              return "Mobile number must 10 digits";
            } else if (!regExp.hasMatch(value)) {
              return "Mobile Number invalid";
            }
          })
        ],
      ),
      controller: _mobileController,
      maxLength: 10,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Mobile No',
      ),
    );
  }

  Widget _buildConsumerNumberField(BuildContext context) {
    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r'[ ,.-]'))],
      validator: validator.add(
        key: 'consumer_number',
        rules: [
          ValidatorX.mandatory(message: "Consumer Number is required"),
        ],
      ),
      controller: _consumerNumberController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Consumer number',
      ),
      style: primaryTextStyle(
        fontFamily: fontMedium,
      ),
    );
  }

  Widget _buildBillNumberField(BuildContext context) {
    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r'[ ,.-]'))],
      validator: validator.add(
        key: 'bill_number',
        rules: [
          ValidatorX.mandatory(message: "Bill number is required"),
        ],
      ),
      controller: _billNumberController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Bill number',
      ),
    );
  }

  Widget _buildCustomerMobileNumberField(BuildContext context) {
    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r'[ ,.-]'))],
      validator: validator.add(
        key: 'mobile',
        rules: [
          ValidatorX.custom((value, {key}) {
            String pattern = r'[6789][0-9]{9}$';
            RegExp regExp = new RegExp(pattern);
            if (value!.length == 0) {
              return "Customer mobile is Required";
            } else if (value.length != 10) {
              return "Customer mobile number must 10 digits";
            } else if (!regExp.hasMatch(value)) {
              return "Customer mobile Number invalid";
            }
          })
        ],
      ),
      controller: _customerMobileNumberController,
      keyboardType: TextInputType.number,
      maxLength: 10,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Customer Mobile Number',
      ),
      style: primaryTextStyle(
        fontFamily: fontMedium,
      ),
    );
  }

  Widget _buildCustomerNameField(BuildContext context) {
    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r'[ ,.-]'))],
      validator: validator.add(
        key: 'customer_name',
        rules: [
          ValidatorX.mandatory(message: "Customer name is required"),
        ],
      ),
      controller: _customerNameController,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Customer Name',
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
      maxLength: 4,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ,-]'))],
      controller: _amountController,
      decoration: InputDecoration(
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

  Widget _buildOperatorField(BuildContext context) {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      validator: validator.add(
        key: 'operator_id',
        rules: [
          ValidatorX.mandatory(message: "Select your operator"),
        ],
      ),
      hint: text('Select your operator', fontFamily: fontMedium, textColor: grey),
      decoration: InputDecoration(border: OutlineInputBorder()),
      value: operatorSelection,
      iconSize: 20,
      elevation: 16,
      onChanged: (String? newValue) {
        validator.clearErrorsAt('operator_id');
        setState(() {
          operatorSelection = newValue!;
        });
      },
      items: gasOperator.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem<String>(
          value: category['id'].toString(),
          child: text(
            category['name'].toString(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
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
      padding: const EdgeInsets.all(0.0),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          textContent: "Proceed".toUpperCase(),
          onPressed: () {
            if (_gasFormKey.currentState!.validate()) {
              FocusScope.of(context).requestFocus(FocusNode());

              Map sendData = {
                'phone': _mobileController.text,
                'consumer_number': _consumerNumberController.text,
                'customer_name': _customerNameController.text,
                'bill_number': _billNumberController.text,
                'amount': _amountController.text,
                // 'financial_password': _transactionPasswordController.text,
                'operator_id': operatorSelection,
              };

              Api.http.post('member/recharge/gas-bill', data: sendData).then((response) {
                if (response.data['status']) {
                  // AppUtils.startTransaction(response.data);
                } else {
                  AppUtils.showErrorSnackBar(response.data['message']);
                }
              }).catchError(
                (error) {
                  if (error.response.statusCode == 422) {
                    validator.setErrors(error.response.data['errors']);
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
