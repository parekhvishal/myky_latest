import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../services/api.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';

class CustomerToVendor extends StatefulWidget {
  const CustomerToVendor({Key? key}) : super(key: key);

  @override
  _CustomerToVendorState createState() => _CustomerToVendorState();
}

class _CustomerToVendorState extends State<CustomerToVendor> {
  List bannerList = [];
  late Future _future;

  Future<Map> getVideo() {
    return Api.http.get("member/my-banners?type=3").then((response) {
      return response.data;
    });
  }

  @override
  void initState() {
    _future = getVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promoter-Vendor'),
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }
          bannerList = snapshot.data['list'];

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // text(
                //   'Choose your Banner',
                //   textAllCaps: true,
                //   fontFamily: fontBold,
                // ),
                // 20.height,
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (int i = 0; i < bannerList.length; i++)
                      _languageVideoBuilder(bannerList[i]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _languageVideoBuilder(item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 15,
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: colorPrimary.withOpacity(0.65),
        child: text(
          item['language'],
          fontFamily: fontBold,
          textColor: whiteColor,
          isCentered: true,
        ),
      ).onTap(() {
        if (item['link'] != null) {
          Get.toNamed(
            '/pdf-viewer',
            arguments: item['link'],
          );
        } else {
          AppUtils.showErrorSnackBar('PDF not found');
        }
      }),
    );
  }
}
