import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key}) : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Summary")),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    height: 15,
                  ),
                  text(
                    "Order Details",
                    fontSize: textSizeLargeMedium,
                    fontFamily: fontBold,
                    textColor: textColorPrimary,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: boxDecoration(showShadow: true, radius: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetail("Booking Id", "123"),
                        SizedBox(
                          height: 5,
                        ),
                        buildDetail("Payment", "Paid: Wallet (\$5) , Credit/Debit Card (\$100)"),
                        SizedBox(
                          height: 5,
                        ),
                        buildDetail("Date", "February 15, 2020 at 10:20 AM"),
                        SizedBox(
                          height: 5,
                        ),
                        buildDetail("Delivered to", "Uyi ,1226 University Dr Wahidin y Dr Wahidin\nContact:9131221311"),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  text(
                    "Payment Summary",
                    fontSize: textSizeLargeMedium,
                    fontFamily: fontBold,
                    textColor: textColorPrimary,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: boxDecoration(showShadow: true, radius: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTotal("Subtotal", "\$100"),
                        SizedBox(
                          height: 2,
                        ),
                        buildTotal("Delivery fee", "\$10"),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          height: 0.8,
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text(
                              "Total",
                              fontSize: textSizeMedium,
                              fontFamily: fontBold,
                              textColor: textColorPrimary,
                            ),
                            text(
                              '\$110',
                              fontSize: textSizeMedium,
                              fontFamily: fontBold,
                              textColor: textColorPrimary,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white.withOpacity(0.5), border: Border.all(color: Colors.red, width: 1)),
                      child: text(
                        "Pin this Order",
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
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => const SupplierRegister(),
                        //     ));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.green.shade100,
                        ),
                        child: text(
                          "Repeat Order",
                          fontSize: textSizeSmall,
                          fontFamily: fontBold,
                          textColor: greenColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Row buildTotal(String priceTitle, String total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        text(
          priceTitle,
          fontSize: textSizeSmall,
          fontFamily: fontMedium,
          textColor: textColorSecondary,
        ),
        SizedBox(
          height: 2,
        ),
        text(
          total,
          fontSize: textSizeSmall,
          fontFamily: fontBold,
          textColor: textColorSecondary,
        ),
      ],
    );
  }

  Widget buildDetail(String title, String subTitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(
          title,
          fontSize: textSizeSmall,
          fontFamily: fontMedium,
          textColor: textColorPrimary,
        ),
        SizedBox(
          height: 2,
        ),
        text(
          subTitle,
          fontSize: textSizeSmall,
          fontFamily: fontBold,
          textColor: textColorPrimary,
        ),
      ],
    );
  }
}
