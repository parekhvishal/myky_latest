import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';

import 'guest_orders_detail.dart';

class UpcomingOrder extends StatefulWidget {
  const UpcomingOrder({Key? key}) : super(key: key);

  @override
  State<UpcomingOrder> createState() => _UpcomingOrderState();
}

class _UpcomingOrderState extends State<UpcomingOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 12,
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              margin: EdgeInsets.only(left: 14, right: 14, bottom: 10),
              decoration: boxDecoration(radius: 12, showShadow: true),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          noImage,
                          height: 80,
                          width: 80,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                text(
                                  "Booking ID",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontMedium,
                                  textColor: textColorPrimary,
                                ),
                                text(
                                  "123",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontBold,
                                  textColor: textColorPrimary,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                text(
                                  "Booking For",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontMedium,
                                  textColor: textColorPrimary,
                                ),
                                text(
                                  "04 Apr 2023,10:42 am",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontBold,
                                  textColor: textColorPrimary,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                text(
                                  "Delivery Date",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontMedium,
                                  textColor: textColorPrimary,
                                ),
                                text(
                                  "12 Apr 2023,05:00 pm",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontBold,
                                  textColor: textColorPrimary,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                text(
                                  "Payment Mode",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontMedium,
                                  textColor: textColorPrimary,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.green.withOpacity(0.5)),
                                  child: text(
                                    "COD",
                                    fontSize: textSizeSmall,
                                    fontFamily: fontBold,
                                    textColor: textColorPrimary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                text(
                                  "Amount",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontMedium,
                                  textColor: textColorPrimary,
                                ),
                                text(
                                  "Rs. 4000",
                                  fontSize: textSizeSmall,
                                  fontFamily: fontBold,
                                  textColor: textColorPrimary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 6.5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 8.5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white.withOpacity(0.5), border: Border.all(color: Colors.red, width: 1)),
                          child: text(
                            "Track Order",
                            fontSize: textSizeSmall,
                            fontFamily: fontBold,
                            textColor: textColorPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OrderDetail(),
                                ));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green.shade100,
                            ),
                            child: text(
                              "View Detail",
                              fontSize: textSizeSmall,
                              fontFamily: fontBold,
                              textColor: greenColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ))
        ],
      ),
    );
  }
}
