import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../widget/widget_extension.dart';

class TopUp extends StatefulWidget {
  @override
  _TopUpState createState() => _TopUpState();
}

class _TopUpState extends State<TopUp> {
  final _topUpFormKey = GlobalKey<FormState>();
  String? myPackageSelection;
  final TextEditingController _memberCodeController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  Map? packageData;
  int payBy = 1;
  ValidatorX validator = ValidatorX();

  late Map topupResponse;
  var pinsData;

  @override
  void initState() {
    super.initState();
    pinsData = Get.arguments;
    setState(() {
      if (pinsData != null) {
        _pinController.text = pinsData;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create TopUp"),
      ),
      body: Form(
        key: _topUpFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                _buildMemberID(),
                SizedBox(height: 20),
                _buildPin(),
                SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberID() {
    return TextFormField(
      validator: validator.add(
        key: 'code',
        rules: [
          ValidatorX.mandatory(message: "Member Id can't be empty"),
        ],
      ),
      onChanged: (value) {
        validator.clearErrorsAt('code');
      },
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
      controller: _memberCodeController,
      decoration: InputDecoration(
        labelText: 'Member ID',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget _buildPin() {
    return TextFormField(
      validator: validator.add(
        key: 'pin',
        rules: [
          ValidatorX.mandatory(message: "Pin can't be empty"),
        ],
      ),
      readOnly: true,
      onChanged: (value) {
        validator.clearErrorsAt('pin');
      },
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
      controller: _pinController,
      decoration: InputDecoration(
        labelText: 'Enter Pin',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: MaterialButton(
        elevation: 0,
        padding: const EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Text("SUBMIT"),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        onPressed: () {
          Map topUpData = {
            'code': _memberCodeController.text,
            'pin': _pinController.text,
          };

          if (_topUpFormKey.currentState!.validate()) {
            FocusScope.of(context).requestFocus(FocusNode());

            Api.http.post('member/top-ups/store', data: topUpData).then((res) {
              if (res.data['status']) {
                showDialogSingleButton(
                  context,
                  {
                    'status': true,
                    'msg': res.data['message'],
                  },
                  isRedirect: true,
                  isCustom: true,
                );
              } else {
                GetBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  message: res.data['message'],
                ).show();
              }
            }).catchError((error) {
              if (error.response.statusCode == 422) {
                setState(() {
                  // validator.setErrors(error.response.data['errors']['code'][0]);
                  GetBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    message: error.response.data['errors']['code'][0],
                  ).show();
                });
              }
            });
          }
        },
      ),
    );
  }
}
