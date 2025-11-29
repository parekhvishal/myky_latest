import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../widget/theme.dart';

class TransactionChangePassword extends StatefulWidget {
  @override
  _TransactionChangePasswordState createState() => _TransactionChangePasswordState();
}

class _TransactionChangePasswordState extends State<TransactionChangePassword> {
  bool _newTransactionConfirmPassword = true;
  bool _oldTransactionPassword = true;
  bool _newTransactionPassword = true;
  ValidatorX validator = ValidatorX();
  final _changeTransactionPasswordFormKey = GlobalKey<FormState>();
  TextEditingController _newTransactionPasswordController = TextEditingController();
  TextEditingController _oldTransactionPasswordController = TextEditingController();
  TextEditingController _confirmTransactionPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 2.0,
        title: Text('Change Transaction Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _changeTransactionPasswordFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: <Widget>[
              _buildOldPasswordField(),
              SizedBox(height: 20),
              _buildNewPasswordField(),
              SizedBox(height: 20),
              _buildConfirmPasswordField(),
              SizedBox(height: 25),
              _buildLoginButton(context),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOldPasswordField() {
    return floatingInput(
      'Old Transaction Password',
      isPassword: _oldTransactionPassword,
      keyboardType: TextInputType.text,
      suffixIcon: GestureDetector(
        child: Icon(
          _oldTransactionPassword ? Icons.visibility_off : Icons.visibility,
          color: colorPrimary,
        ),
        onTap: () {
          setState(() {
            _oldTransactionPassword = !_oldTransactionPassword;
          });
        },
      ),
      controller: _oldTransactionPasswordController,
      validator: validator.add(
        key: 'old_password',
        rules: [
          ValidatorX.mandatory(message: "Old transaction password can't be empty"),
        ],
      ),
      onChanged: (value) {
        validator.clearErrorsAt('old_password');
      },
    );
  }

  Widget _buildNewPasswordField() {
    return floatingInput(
      'New Transaction Password',
      isPassword: _newTransactionPassword,
      keyboardType: TextInputType.text,
      suffixIcon: GestureDetector(
        child: Icon(
          _newTransactionPassword ? Icons.visibility_off : Icons.visibility,
          color: colorPrimary,
        ),
        onTap: () {
          setState(() {
            _newTransactionPassword = !_newTransactionPassword;
          });
        },
      ),
      controller: _newTransactionPasswordController,
      validator: validator.add(
        key: 'password',
        rules: [
          ValidatorX.mandatory(message: "New transaction password can't be empty"),
        ],
      ),
      onChanged: (value) {
        validator.clearErrorsAt("password");
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return floatingInput(
      'Confirm New Transaction Password',
      isPassword: _newTransactionConfirmPassword,
      keyboardType: TextInputType.text,
      suffixIcon: GestureDetector(
        child: Icon(
          _newTransactionConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: colorPrimary,
        ),
        onTap: () {
          setState(() {
            _newTransactionConfirmPassword = !_newTransactionConfirmPassword;
          });
        },
      ),
      controller: _confirmTransactionPasswordController,
      validator: validator.add(
        key: 'password_confirmation',
        rules: [ValidatorX.mandatory(message: "Confirm new transaction password can't be empty"), ValidatorX.confirm(_newTransactionPasswordController, "confirm Password")],
      ),
      onChanged: (value) {
        validator.clearErrorsAt('password_confirmation');
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return CustomButton(
      textContent: 'Change Password',
      onPressed: () {
        if (_changeTransactionPasswordFormKey.currentState!.validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          Map sendData = {
            'old_password': _oldTransactionPasswordController.text,
            'password': _newTransactionPasswordController.text,
            'password_confirmation': _confirmTransactionPasswordController.text,
          };

          Api.http.post('member/profile/change-transaction-password', data: sendData).then((response) {
            GetBar(
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              message: response.data['message'],
            ).show();

            Timer(Duration(seconds: 3), () {
              Get.offAllNamed("/dashboard");
            });
          }).catchError((error) {
            if (error.response.statusCode == 422) {
              setState(() {
                validator.setErrors(error.response.data['errors']);
              });
            }
          });
        }
      },
    );
  }
}
