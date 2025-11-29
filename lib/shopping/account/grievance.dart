import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../services/api.dart';
import '../../widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';

class Grievance extends StatefulWidget {
  const Grievance({Key? key}) : super(key: key);

  @override
  State<Grievance> createState() => _GrievanceState();
}

class _GrievanceState extends State<Grievance> {
  var linkResponse;

  @override
  void initState() {
    fetchWebLinks();
    // TODO: implement initState
    super.initState();
  }

  void fetchWebLinks() {
    Api.httpWithoutLoader.get('shopping/web-links').then((response) {
      setState(() {
        if (response.data['status']) {
          linkResponse = response.data;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('Grievance Redressal'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
        child: linkResponse != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text('Grievance',
                      fontSize: 15.0,
                      fontFamily: fontBold,
                      textColor: Colors.black),
                  10.height,
                  buildRow(Icons.account_circle_rounded, "Name",
                      linkResponse['grievanceName'] ?? 'N/A'),
                  15.height,
                  buildRow(Icons.mobile_friendly, "Mobile No",
                      linkResponse['grievanceMobile'] ?? 'N/A'),
                  15.height,
                  buildRow(Icons.email, "Email",
                      linkResponse['grievanceEmail'] ?? 'N/A'),
                  15.height,
                  text('Redressal',
                      fontSize: 15.0,
                      fontFamily: fontBold,
                      textColor: Colors.black),
                  15.height,
                  buildRow(Icons.email, "Email",
                      linkResponse['redressalName'] ?? 'N/A'),
                  15.height,
                  buildRow(Icons.mobile_friendly, "Mobile No",
                      linkResponse['redressalMobile'] ?? 'N/A'),
                  15.height,
                  buildRow(Icons.email, "Email",
                      linkResponse['redressalEmail'] ?? 'N/A'),
                ],
              )
            : SizedBox(),
      ),
    );
  }

  Widget buildRow(IconData data, String title, String result) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
            Color(0x194343b2).withOpacity(0.15),
            offset: const Offset(
              5.0,
              5.0,
            ),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ), //BoxShadow
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            data,
            color: colorPrimary,
            size: 22,
          ),
          10.width,
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(title,
                  fontSize: 12.0, fontFamily: fontMedium, textColor: gray),
              0.height,
              text(result,
                  fontSize: 15.0,
                  fontFamily: fontBold,
                  textColor: Colors.black),
            ],
          )
        ],
      ),
    );
  }
}
