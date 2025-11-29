import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../widget/customWidget.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class PinList extends StatefulWidget {
  @override
  _PinListState createState() => _PinListState();
}

class _PinListState extends State<PinList> {
  List _selectedPins = [];

  TextEditingController _codeController = TextEditingController();

  late Map<String, dynamic> _errors;

  final _transferPinFormKey = GlobalKey<FormState>();

  GlobalKey<PaginatedListState> pinsPaginatedListKey = GlobalKey();

  late Map pinStatus;

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      key: pinsPaginatedListKey,
      pageTitle: 'Pins',
      apiFuture: (int page) async {
        return Api.http.get("member/pin?page=$page").then((res) {
          if (res.data['status']) {
            pinStatus = res.data['statuses'];
          }
          return res;
        });
      },
      listItemGetter: (data) {
        data['checked'] = false;
        return data;
      },
      resetStateOnRefresh: true,
      listItemBuilder: _pinBuilder,
      refreshPerformActionCallback: () {
        setState(() {
          _selectedPins = [];
        });
      },
      floatingActionButton: Visibility(
        visible: _selectedPins.length > 0,
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Transfer To'),
                    content: Form(
                      key: _transferPinFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(new RegExp(r'[- ,.]')),
                        ],
                        textCapitalization: TextCapitalization.characters,
                        validator: (code) {
                          if (code!.isEmpty) {
                            return "Member ID can't be empty";
                          }
                          if (_errors.containsKey('code')) {
                            return _errors['code'][0];
                          }
                          return null;
                        },
                        controller: _codeController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Member ID',
                          hintText: 'OS98512447',
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Transfer Pin'),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_transferPinFormKey.currentState!.validate()) {
                            Api.http.post('member/pin/pin-transfer', data: {
                              "code": _codeController.text,
                              "pins": _selectedPins,
                            }).then((res) {
                              if (res.data['status']) {
                                _codeController.clear();
                                Navigator.of(context).pop();
                                showDialogSingleButton(
                                  context,
                                  {
                                    'status': true,
                                    'msg': res.data['message'],
                                  },
                                  customCode: pinsPaginatedListKey,
                                );
                              } else {
                                showDialogSingleButton(
                                  context,
                                  {
                                    'status': false,
                                    'msg': res.data['error'],
                                  },
                                );
                              }
                            }).catchError((error) {
                              if (error.response.statusCode == 422) {
                                setState(() {
                                  _errors = error.response.data['errors'];
                                });
                                showDialogSingleButton(
                                  context,
                                  {
                                    'status': false,
                                    'msg': error.response.data['errors']['code'][0],
                                  },
                                );
                              }
                            });
                          }
                        },
                      ),
                    ],
                  );
                });
          },
          label: Text('Transfer Pin'),
          icon: Icon(Icons.attach_file),
        ),
      ),
    );
  }

  Widget _pinBuilder(dynamic item, int index) {
    return Container(
      decoration: boxDecoration(radius: 10, showShadow: true),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (item['status']['id'] == 1)
                Checkbox(
                  value: item['checked'],
                  onChanged: (bool? value) {
                    setState(() {
                      item['checked'] = value;
                      if (value!) {
                        _selectedPins.add(item['pin']);
                      } else {
                        _selectedPins.remove(item['pin']);
                      }
                    });
                  },
                ),
              text(item['createdAt']),
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  child: text(
                    item['status']['name'].toString().toUpperCase(),
                    textColor: white,
                    fontFamily: fontSemibold,
                  ),
                ),
                color: item['status']['id'] == 2
                    ? Colors.amber
                    : item['status']['id'] == 1
                        ? green
                        : Colors.black,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    text(
                      "${item['package']}  | \₹ ${item['amount']}",
                      fontFamily: fontBold,
                      textColor: colorPrimary,
                      isLongText: true,
                      // maxLineApplicable: false,
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          text(
                            item['pin'],
                            textColor: red,
                            fontSize: textSizeMedium,
                            fontFamily: fontBold,
                            // latterSpacing: 0.8,
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                new ClipboardData(text: item['pin']),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Text Copied to Clipboard'),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.content_copy,
                              size: 14,
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 5),
          if (item['usedBy'] != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                text(
                  'Used By',
                  fontSize: textSizeMedium,
                  fontFamily: fontSemibold,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      text(" ${item['usedBy']['name']} | ${item['usedBy']['code']}", fontSize: textSizeMedium, maxLine: 4, isLongText: true),
                    ],
                  ),
                )
              ],
            ),
          if (item['status']['id'] == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    Get.toNamed('/top-up-mlm', arguments: item['pin'])!.then((value) => pinsPaginatedListKey.currentState!.refresh());
                  },
                  child: text('TopUp', textColor: white),
                  color: colorPrimary,
                ),
              ],
            )
        ],
      ),
    );
  }
}
