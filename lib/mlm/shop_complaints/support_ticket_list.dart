import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/api.dart';
import '../../utils/app_utils.dart';
import '../../utils/en_extensions.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class HelpCenterList extends StatefulWidget {
  const HelpCenterList({super.key});

  @override
  HelpCenterListState createState() => HelpCenterListState();
}

class HelpCenterListState extends State<HelpCenterList> {
  final GlobalKey<PaginatedListState> _helpCenterPaginatedListKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline shop Complaints"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/create-ticket')!.then((value) {
            if (value != null && value) {
              _helpCenterPaginatedListKey.currentState!.refresh();
            }
          });
        },
        child: Icon(Icons.add),
      ),
      body: PaginatedList(
        key: _helpCenterPaginatedListKey,
        resetStateOnRefresh: true,
        isDescription: false,
        noDataTitle: 'Offline Shop Complaints',
        apiFuture: (page) async {
          return await Api.http.get('member/offline-store-complaint?page=$page');
        },
        listItemBuilder: _helpCenterTicketBuilder,
      ).marginSymmetric(vertical: 10.h, horizontal: 10.w),
    );
  }

  Widget _helpCenterTicketBuilder(data, index) {
    return Column(
      children: <Widget>[
        _ticketContent(data),
      ],
    );
  }

  Widget _statusButton(data) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: AppUtils.setStatusColor(data['status']['name']).withOpacity(0.2),
            borderRadius: BorderRadius.all(
              Radius.circular(8.r),
            ),
          ),
          child: text(
            data['status']['name'],
            fontSize: 12.sp,
            fontFamily: fontSemibold,
            textColor: AppUtils.setStatusColor(data['status']['name']),
          ),
        ),
        if (data['unreadCount'] != null && data['unreadCount'] > 0) ...[
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              alignment: Alignment.center,
              height: 18.sp,
              width: 18.sp,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: text(
                '${data['unreadCount']}',
                textColor: Colors.white,
                fontFamily: fontBold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _ticketContent(data) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: boxContain(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                data['createdAt'],
                fontSize: 14.sp,
                // textColor: white,
                fontFamily: fontBold,
              ),
              _statusButton(data),
            ],
          ),
          5.heightBox,
          dottedLine(),
          8.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                "Issue Type : ",
                fontSize: 13.sp,
                textColor: Colors.grey,
              ),
              text(
                data['complaintType']['name'],
                fontSize: 13.sp,
                textColor: colorAccent,
                fontFamily: fontSemibold,
              ),
            ],
          ),
          8.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                "Vendor Name : ",
                fontSize: 13.sp,
                textColor: Colors.grey,
              ),
              text(
                data['vendorName'] ?? 'N/A',
                fontSize: 13.sp,
                textColor: colorAccent,
                fontFamily: fontSemibold,
              ),
            ],
          ),
          8.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                "Vendor ID : ",
                fontSize: 13.sp,
                textColor: Colors.grey,
              ),
              text(
                data['vendorCode'].toString(),
                fontSize: 13.sp,
                textColor: colorAccent,
                fontFamily: fontSemibold,
              ),
            ],
          ),
        ],
      ).appPadding().onTap(() {
        Get.toNamed('/ticket-detail', arguments: data);
      }),
    );
  }
}
