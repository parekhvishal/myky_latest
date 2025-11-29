import 'package:flutter/material.dart';

class ValidatorX {
  Map _errors = {};

  String? Function(String?)? add({
    @required String? key,
    List<Function> rules = const [],
  }) {
    return (String? value) {
      for (Function rule in rules) {
        var error = rule(value ?? '', key: key);
        if (error is String) {
          return error;
        }
      }

      if (_errors.containsKey(key)) {
        return _errors[key][0].toString();
      }

      return null;
    };
  }

  void setErrors(Map errors) {
    _errors = errors;
  }

  void clearErrorsAt(String key) {
    _errors.remove(key);
  }

  static _getMessage({String message = '', String defaultMessage = ''}) {
    return message.isNotEmpty ? message : defaultMessage;
  }

  static Function mandatory({String? message = ''}) {
    return (String value, {String? key}) {
      if (value == '') {
        return _getMessage(
          message: message!,
          defaultMessage: 'The $key field is required',
        );
      }

      return null;
    };
  }

  static Function minLength({@required int? length, String? message = ''}) {
    return (String value, {String? key}) {
      if (value.length < length!) {
        return _getMessage(
          message: message!,
          defaultMessage: 'The $key field should contain at-least $length characters.',
        );
      }

      return null;
    };
  }

  static Function email({String? message = ''}) {
    return (String value, {String? key}) {
      if (!RegExp(
              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
          .hasMatch(value)) {
        return _getMessage(
          message: message!,
          defaultMessage: 'The $key field is not a valid email address',
        );
      }

      return null;
    };
  }

  static custom(String? Function(String? value, {String? key}) callback) {
    return callback;
  }

  static customWithFutureFunction(
      Future<String?> Function(String? value, {String? key}) callback) async {
    return await callback;
  }

  static confirm(TextEditingController passwordTextController, String? showName,
      {String? message = ''}) {
    return (String value, {String? key}) {
      if (passwordTextController.text != value) {
        return _getMessage(
          message: message!,
          defaultMessage: '$showName is not matching',
        );
      }
    };
  }
}
