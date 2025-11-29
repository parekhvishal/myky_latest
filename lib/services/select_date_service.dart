import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

import '../widget/theme.dart';

class SelectDateFromCalender {
  String? date;

  SelectDateFromCalender._internal();
  DateTime initialDate = DateTime.now().toUtc();
  late DateTime selectedDate;

  static final SelectDateFromCalender _instance = SelectDateFromCalender._internal();

  static SelectDateFromCalender get instance => _instance;

  Future datePickerInit() async {
    initialDate = await NTP.now();
    initialDate = initialDate.toUtc();
    selectedDate = initialDate;
  }

  resetDate() {
    datePickerInit();
  }

  selectDate(BuildContext context) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      // initialDate: DateTime.now().toUtc(),
      initialDate: selectedDate,
      firstDate: DateTime(1900).toUtc(),
      lastDate: DateTime(2040).toUtc(),
      helpText: 'Select Date',
      cancelText: "CANCEL",
      confirmText: "SAVE",
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      currentDate: selectedDate,
      selectableDayPredicate: _decideWhichDayToEnable,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorPrimary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDate != null) {
      date = DateFormat('yyyy-MM-dd').format(newDate);
      selectedDate = newDate;
    } else {
      date = null;
    }

    return date;
  }

  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(initialDate.subtract(const Duration(days: 36500))) &&
        day.isBefore(initialDate.add(const Duration(days: 0))))) {
      return true;
    }
    return false;
  }
}
