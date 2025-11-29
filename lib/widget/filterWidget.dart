import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import '../../services/extension.dart';
import '../../widget/theme.dart';

class FilterWidget extends StatefulWidget {
  final Function? filterSort;
  final Function? filterCategory;
  final Function? filterGender;
  final Function? filterData;

  const FilterWidget({
    Key? key,
    this.filterSort,
    this.filterCategory,
    this.filterGender,
    this.filterData,
  }) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Icon(UniconsLine.sort_amount_up, size: 20),
                  ),
                  3.width,
                  text(
                    'Sort',
                    fontFamily: fontBold,
                    fontSize: textSizeSMedium,
                  ),
                ],
              ),
            ).onClick(widget.filterSort),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  text(
                    'Category',
                    fontFamily: fontBold,
                    fontSize: textSizeSMedium,
                  ),
                  3.width,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Icon(UniconsLine.angle_down, size: 20),
                  ),
                ],
              ),
            ).onClick(widget.filterCategory),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  text(
                    'Gender',
                    fontFamily: fontBold,
                    fontSize: textSizeSMedium,
                  ),
                  3.width,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Icon(UniconsLine.angle_down, size: 20),
                  ),
                ],
              ),
            ).onClick(widget.filterGender),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Icon(UniconsLine.filter, size: 18),
                  ),
                  3.width,
                  text(
                    'Filters',
                    fontFamily: fontBold,
                    fontSize: textSizeSMedium,
                  ),
                ],
              ),
            ).onClick(widget.filterData),
          ),
        ],
      ),
    );
  }
}
