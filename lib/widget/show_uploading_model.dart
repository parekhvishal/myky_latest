import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myky_clone/widget/theme.dart';

import 'inner_shadow.dart';

void showUploadingDialog(BuildContext context, indexController) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.r))),
        child: StreamBuilder(
          stream: indexController.stream,
          initialData: 0,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            return InnerShadowContainer(
              color: white,
              borderColor: colorAccent,
              offset: const Offset(0, 5),
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text(
                    'Uploading... ${snapshot.data}%',
                    textColor: colorPrimary,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Container(
                    padding: const EdgeInsets.all(1),
                    width: 150.w,
                    height: 15.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.r),
                      ),
                      child: LinearProgressIndicator(
                        value: (snapshot.hasData && snapshot.data! < 100)
                            ? convertToDecimal(snapshot.data)
                            : 1.0,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff20a872)),
                        backgroundColor: const Color(0xffD6D6D6),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

convertToDecimal(value) {
  return value / 100;
}
