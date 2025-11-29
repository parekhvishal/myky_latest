import 'package:another_stepper/dto/stepper_data.dart';
import 'package:another_stepper/widgets/another_stepper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../widget/theme.dart';

class TrackShipment extends StatefulWidget {
  const TrackShipment({Key? key}) : super(key: key);

  @override
  State<TrackShipment> createState() => _TrackShipmentState();
}

class _TrackShipmentState extends State<TrackShipment> {
  var orderData;
  Map? previousPageData;
  int? id;
  late Future trackShipment;
  List<StepperData>? stepperData;

  List? shippingInformation;

  @override
  void initState() {
    previousPageData = Get.arguments;
    id = previousPageData!['orderProductId'];
    trackShipment = orderDetails();
    // TODO: implement initState
    super.initState();
  }

  Future orderDetails() {
    return Api.http.post("shopping/order/track-shipment/$id",
        queryParameters: {"user_type": Auth.check()! ? 1 : 2}).then((response) {
      setState(() {
        orderData = response.data;
        shippingInformation = orderData['data'];
        stepperData = [
          for (int i = 0; i < shippingInformation!.length; i++)
            StepperData(
                title: StepperText(
                  shippingInformation![i]['status'],
                  textStyle: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                subtitle: StepperText(
                    '${shippingInformation![i]['location_city']} | ${shippingInformation![i]['updated_on']}'),
                iconWidget: Container(
                  child: Center(
                    child: (i == 0)
                        ? Icon(
                            Icons.circle,
                            color: Colors.white,
                          )
                        : Container(),
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                )),
        ];
      });

      return response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('Order Shipment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text('${previousPageData!['subOrderNo']}'),
              10.height,
              text('AWB No : ${previousPageData!['awbNumber']}'),
              10.height,
              if (stepperData != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: AnotherStepper(
                    stepperList: stepperData!,
                    stepperDirection: Axis.vertical,
                    iconWidth: 40,
                    iconHeight: 40,
                    activeBarColor: Colors.green,
                    inActiveBarColor: Colors.green,
                    verticalGap: 30,
                    activeIndex: 1,
                    barThickness: 8,
                  ),
                ),
              if (previousPageData!['trackingUrl'] != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0), color: Colors.lightBlue),
                      child: Center(
                          child: text('VIEW DETAILS', textColor: Colors.white, fontSize: 12.0)),
                    ).onTap(() {
                      launch(previousPageData!['trackingUrl']);
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
