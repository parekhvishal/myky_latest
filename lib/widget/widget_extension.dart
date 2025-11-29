import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDialogSingleButton(BuildContext context, Map data, {bool isRedirect = false, bool isCustom = false}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(right: 16.0),
            height: 150,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(75), bottomLeft: Radius.circular(75), topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
            child: Row(
              children: <Widget>[
                SizedBox(width: 20.0),
                CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      data['status'] ? Icons.done : Icons.close,
                      color: data['status'] ? Colors.green : Colors.red,
                      size: 60.0,
                    )),
                SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data['status'] ? "Success!" : "Oops!!!",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 10.0),
                      Flexible(
                        child: Text(data['msg']),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          MaterialButton(
                            child: Text("Ok"),
                            color: Colors.green,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              // isRedirect==true?
                              // Navigator.pop(context);
                              Get.back();
                              if (isRedirect) Get.back();
                              if (isCustom) Get.toNamed('topup-view');
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
