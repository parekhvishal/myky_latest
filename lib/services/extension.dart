import 'package:flutter/material.dart';

extension StringExtension on String? {
  bool get isEmptyOrNull => this == null || this!.isEmpty || this == 'null';

  bool get isNotEmptyOrNull => !(this == null || this!.isEmpty || this == 'null');

  String get toCapitalized => this!.length > 0 ? '${this![0].toUpperCase()}${this!.substring(1).toLowerCase()}' : '';

  String get toTitleCase => this!.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.toCapitalized).join(" ");

  get removeAllHtmlTags {
    if (this.isNotEmptyOrNull) {
      RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true,
      );
      return this!.replaceAll(exp, '');
    } else
      return null;
  }
}

extension WidgetExtension on Widget? {
  Widget onClick(Function? function) {
    return InkWell(
      onTap: function as void Function()?,
      child: this,
    );
  }

  Widget paddingAll({double padding = 10}) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }

  Widget paddingSymmetric({double horizontal = 10, double vertical = 10}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: this,
    );
  }

  Widget addRoundedContainer({
    double radius = 10,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: color,
      ),
      child: this,
    );
  }
}

extension IntExtension on int {
  Widget get height => SizedBox(height: this.toDouble());

  Widget get width => SizedBox(width: this.toDouble());
}
