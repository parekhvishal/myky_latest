import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _newConfirmPassword = true;
  bool _oldPassword = true;
  bool _newPassword = true;
  ValidatorX validator = ValidatorX();
  final _changePasswordFormKey = GlobalKey<FormState>();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 2.0,
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _changePasswordFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 10),
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
      'Old Password',
      isPassword: _oldPassword,
      keyboardType: TextInputType.text,
      suffixIcon: GestureDetector(
        child: Icon(
          _oldPassword ? Icons.visibility_off : Icons.visibility,
          color: colorPrimary,
        ),
        onTap: () {
          setState(() {
            _oldPassword = !_oldPassword;
          });
        },
      ),
      controller: _oldPasswordController,
      validator: validator.add(
        key: 'old_password',
        rules: [
          ValidatorX.mandatory(message: "Old password can't be empty"),
        ],
      ),
      onChanged: (value) {
        validator.clearErrorsAt('old_password');
      },
    );
  }

  Widget _buildNewPasswordField() {
    return floatingInput(
      'New Password',
      isPassword: _newPassword,
      keyboardType: TextInputType.text,
      suffixIcon: GestureDetector(
        child: Icon(
          _newPassword ? Icons.visibility_off : Icons.visibility,
          color: colorPrimary,
        ),
        onTap: () {
          setState(() {
            _newPassword = !_newPassword;
          });
        },
      ),
      controller: _newPasswordController,
      validator: validator.add(
        key: 'password',
        rules: [
          ValidatorX.mandatory(message: "New Password Can't be empty"),
        ],
      ),
      onChanged: (value) {
        validator.clearErrorsAt("password");
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return floatingInput(
      'Confirm New Password',
      isPassword: _newConfirmPassword,
      keyboardType: TextInputType.text,
      suffixIcon: GestureDetector(
        child: Icon(
          _newConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: colorPrimary,
        ),
        onTap: () {
          setState(() {
            _newConfirmPassword = !_newConfirmPassword;
          });
        },
      ),
      controller: _confirmPasswordController,
      validator: validator.add(
        key: 'password_confirmation',
        rules: [ValidatorX.mandatory(message: "Confirm new password can't be empty"), ValidatorX.confirm(_newPasswordController, "confirm Password")],
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
        if (_changePasswordFormKey.currentState!.validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          Api.http.post('member/profile/change-password', data: {
            'old_password': _oldPasswordController.text,
            'password': _newPasswordController.text,
            'password_confirmation': _confirmPasswordController.text,
          }).then((response) {
            if (response.data['status']) {
              Get.back();
              AppUtils.showSuccessSnackBar(response.data['message']);
            } else {
              AppUtils.showErrorSnackBar(response.data['message']);
            }
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
