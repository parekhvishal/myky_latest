import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../widget/theme.dart';

class WithdrawalCreate extends StatefulWidget {
  @override
  _WithdrawalCreateState createState() => _WithdrawalCreateState();
}

class _WithdrawalCreateState extends State<WithdrawalCreate> {
  final _withdrawalRequestFormkey = GlobalKey<FormState>();

  ValidatorX validator = ValidatorX();
  TextEditingController _amountController = TextEditingController();

  Map? fundData;
  String? myPaymentSelection;

  Map? walletBalanceData;
  void getFundData() async {
    Api.http.get('member/withdrawal-request/create').then((response) {
      setState(() {
        fundData = response.data;
      });
    }).catchError((error) {});
  }

  void walletBalance() {
    Api.http.get('member-balance').then((response) async {
      if (response.data['status']) {
        setState(() {
          walletBalanceData = response.data;
        });
      }
    });
  }

  @override
  void initState() {
    getFundData();
    walletBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfafafa),
      appBar: AppBar(title: Text('Withdrawal Request')),
      body: Form(
          key: _withdrawalRequestFormkey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: ListView(
              children: <Widget>[
                _buildAmount(),
                SizedBox(height: 20),
                walletTypeBuild(),
                SizedBox(height: 20),
                _buildButton(),
              ],
            ),
          )),
    );
  }

  Widget walletTypeBuild() {
    return walletBalanceData != null ? text('Your wallet balance ${walletBalanceData!['wallet_balance']}') : SizedBox.shrink();
  }

  Widget _buildAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[0]|[ ,-]'))],
          controller: _amountController,
          validator: validator.add(
            key: 'amount',
            rules: [
              ValidatorX.mandatory(message: 'The amount field is required '),
            ],
          ),
          onChanged: (String value) {
            validator.clearErrorsAt('amount');
          },
          cursorColor: Colors.deepOrange,
          decoration: InputDecoration(
            hintText: "Amount",
            labelText: "Amount",
            border: OutlineInputBorder(),
          ),
        )
      ],
    );
  }

  Widget _buildButton() {
    return CustomButton(
      textContent: 'Submit',
      onPressed: () {
        Map sendData = {
          'amount': _amountController.text,
          'wallet': "1",
        };
        if (_withdrawalRequestFormkey.currentState!.validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          Api.http.post("member/withdrawal-request/store", data: sendData).then((response) {
            GetBar(
              backgroundColor: response.data['status'] ? Colors.green : Colors.red,
              duration: Duration(seconds: 3),
              message: response.data['status'] ? response.data['message'] : response.data['message'],
            ).show();

            Future.delayed(Duration(seconds: 3), () => Get.back());
          }).catchError((error) {
            if (error.response.statusCode == 401 || error.response.statusCode == 403) {
              GetBar(
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
                message: error.response.data['message'],
              ).show();
            }
            if (error.response.statusCode == 422) {
              validator.setErrors(error.response.data['errors']);
            }
          });
        }
      },
    );
  }
}
