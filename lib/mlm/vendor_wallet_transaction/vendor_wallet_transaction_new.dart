import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../services/api.dart';
import '../../services/select_date_service.dart';
import '../../utils/app_utils.dart';
import '../../widget/custom_container.dart';
import '../../widget/custom_select_date_button.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class VendorWalletTransactionNew extends StatefulWidget {
  const VendorWalletTransactionNew({super.key});

  @override
  State<VendorWalletTransactionNew> createState() => _VendorWalletTransactionNewState();
}

class _VendorWalletTransactionNewState extends State<VendorWalletTransactionNew> {
  DateTime dateFrom = DateTime.now(), dateTo = DateTime.now();
  String fromDate = 'DATE', toDate = 'DATE';
  String fromDisplayDate = 'DATE', toDisplayDate = 'DATE';
  DateTime? selectedFromDate, selectedToDate;
  bool? isFromDateSelected = false, isToDateSelected = false;
  final List itemsState = [
    {
      "id": 1,
      "name": 'Credit',
    },
    {
      "id": 2,
      "name": 'Debit',
    },
  ];
  String? selectedType, vendorWalletBalance;
  GlobalKey<PaginatedListState> vendorWalletTransactionGlobalKey = GlobalKey();

  var fromDateFromCalender = SelectDateFromCalender.instance;
  var toDateFromCalender = SelectDateFromCalender.instance;

  @override
  void initState() {
    fromDateFromCalender.datePickerInit();
    toDateFromCalender.datePickerInit();
    SelectDateFromCalender.instance.datePickerInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Wallet Transaction"),
      ),
      body: CustomContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vendorWalletBalance != null) ...[
              walletBalance(),
              12.heightBox,
            ],
            dateSelectionFilter(context),
            12.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 40.h,
                  padding: EdgeInsets.only(right: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11.r),
                    border: Border.all(
                      color: gray,
                      width: 1.w,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      isExpanded: true,
                      // icon: SvgPicture.asset(icon_down_arrow),
                      hint: Text(
                        "Select Type",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                          fontFamily: fontMedium,
                        ),
                      ),
                      items: itemsState
                          .map((item) => DropdownMenuItem<String>(
                                value: item['id'].toString(),
                                child: Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                    fontFamily: fontMedium,
                                  ),
                                ),
                              ))
                          .toList(),
                      value: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value as String;
                        });
                      },
                    ),
                  ),
                ).expand(),
                12.widthBox,
                Container(
                  decoration: boxDecoration(bgColor: colorAccent, radius: 8.r),
                  padding: EdgeInsets.symmetric(
                    vertical: 5.h,
                    horizontal: 12.w,
                  ),
                  child: text(
                    "Apply",
                    fontSize: 14.sp,
                    textColor: white_color,
                  ),
                ).onTap(() {
                  vendorWalletBalance = null;
                  vendorWalletTransactionGlobalKey.currentState?.refresh();
                }),
                12.widthBox,
                Container(
                  decoration: boxDecoration(bgColor: red, radius: 8.r),
                  padding: EdgeInsets.symmetric(
                    vertical: 5.h,
                    horizontal: 12.w,
                  ),
                  child: text(
                    "Reset",
                    fontSize: 14.sp,
                    textColor: white_color,
                  ),
                ).onTap(() {
                  setState(() {
                    vendorWalletBalance = null;
                    fromDate = 'DATE';
                    fromDisplayDate = 'DATE';
                    toDate = 'DATE';
                    toDisplayDate = 'DATE';
                    selectedType = null;
                  });
                  vendorWalletTransactionGlobalKey.currentState?.refresh();
                }),
              ],
            ),
            12.heightBox,
            Expanded(
              child: PaginatedList(
                key: vendorWalletTransactionGlobalKey,
                resetStateOnRefresh: true,
                noDataTitle: "Vendor Wallet Transaction",
                apiFuture: (int page) async {
                  return Api.http.get(
                    'member/vendor-wallet-transaction?page=$page',
                    queryParameters: {
                      if (fromDate != 'DATE') "fromDate": fromDate,
                      if (toDate != 'DATE') "toDate": toDate,
                      "type": selectedType,
                    },
                  ).then((response) {
                    if (vendorWalletBalance == null) {
                      setState(() {
                        vendorWalletBalance = response.data['vendorWalletBalance'] is String
                            ? response.data['vendorWalletBalance']
                            : response.data['vendorWalletBalance'].toString();
                      });
                    }
                    return response;
                  });
                },
                listItemBuilder: vendorWalletTransactionViewBuilder,
              ),
            )
          ],
        ),
      ),
    );
  }

  dateSelectionFilter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        fromDateFilter(context),
        text(
          "to",
          textColor: colorPrimary,
          fontFamily: fontBold,
        ).marginSymmetric(horizontal: 6.w),
        toDateFilter(context),
      ],
    );
  }

  Container walletBalance() {
    return Container(
      decoration: boxDecoration(radius: 12.r),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 8.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30.sp,
            width: 30.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorPrimary.withOpacity(0.2),
            ),
            child: Icon(
              Icons.wallet,
              size: 17.sp,
              color: colorPrimary,
            ),
          ),
          12.widthBox,
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(
                "Wallet Balance",
                fontFamily: fontMedium,
                fontSize: 12.sp,
              ),
              5.heightBox,
              text(
                "$vendorWalletBalance",
                fontFamily: fontBold,
                textColor: colorPrimary,
                fontSize: 16.sp,
              ),
            ],
          ).expand()
        ],
      ),
    );
  }

  Widget fromDateFilter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              fromDateFromCalender.selectDate(context).then((value) {
                if (value != null) {
                  setState(() {
                    fromDate = value;
                    isFromDateSelected = true;
                    fromDisplayDate = AppUtils.changeDateFormat(value);
                  });
                }
                return null;
              });
              // SelectDateFromCalender.instance.selectDate(context).then((value) {
              //   if (value != null) {
              //     setState(() {
              //       date = value;
              //       isDateSelected = true;
              //       displayDate = AppUtils.changeDateFormat(value);
              //     });
              //   }
              //   return null;
              // });
            },
            child: CustomSelectDateContainer(
              onTap: () {
                fromDateFromCalender.resetDate();
                setState(
                  () {
                    fromDate = 'DATE';
                    fromDisplayDate = 'DATE';
                    isFromDateSelected = false;
                  },
                );
                // controller.incomeWallet.currentState!.refreshData();
              },
              title: fromDisplayDate.isNotEmpty ? fromDisplayDate : "DATE",
              isCloseVisible: fromDate.isNotEmpty && fromDate != "DATE" ? true : false,
            ),
          ),
        ),
      ],
    );
  }

  Widget toDateFilter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              toDateFromCalender.selectDate(context).then((value) {
                if (value != null) {
                  setState(() {
                    toDate = value;
                    isToDateSelected = true;
                    toDisplayDate = AppUtils.changeDateFormat(value);
                  });
                }
                return null;
              });
            },
            child: CustomSelectDateContainer(
              onTap: () {
                toDateFromCalender.resetDate();
                setState(
                  () {
                    toDate = 'DATE';
                    toDisplayDate = 'DATE';
                    isToDateSelected = false;
                  },
                );
              },
              title: toDisplayDate.isNotEmpty ? toDisplayDate : "DATE",
              isCloseVisible: toDate.isNotEmpty && toDate != "DATE" ? true : false,
            ),
          ),
        ),
      ],
    );
  }

  Widget vendorWalletTransactionViewBuilder(item, int index) {
    return Container(
      decoration: boxDecoration(radius: 12.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LineIcons.calendar,
                color: colorPrimary,
                size: 28.sp,
              ),
              8.widthBox,
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(item['date']),
                ],
              ).expand(),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 3.h,
                  horizontal: 8.w,
                ),
                decoration: boxDecoration(
                  bgColor:
                      item['type'].toString().toLowerCase() == "debit" ? Colors.red : Colors.green,
                  radius: 8.r,
                ),
                child: text(
                  item['type'],
                  fontSize: 15.0,
                  textColor: white_color,
                  fontFamily: fontBold,
                ),
              )
            ],
          ).marginSymmetric(horizontal: 12.w),
          8.heightBox,
          rowHeading(
            "Amount",
            '\₹ ${item['amount']}',
          ),
          4.heightBox,
          rowHeading(
            "Profit Shared",
            '\₹ ${item['companyCharge']}',
          ),
          4.heightBox,
          rowHeading(
            "GST Amount",
            '\₹ ${item['gstAmount']}',
          ),
          4.heightBox,
          rowHeading(
            "Payable Amount",
            '\₹ ${item['total']}',
          ),
          4.heightBox,
          RichText(
            text: TextSpan(
              text: "Remarks :",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: fontRegular,
              ),
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.w),
                  ),
                ),
                TextSpan(
                  // text: 'Offline Store purchase from NANDHANA(100017) of à¤° 4366',
                  text: item['remark'],
                  style: TextStyle(
                    fontSize: 14,
                    color: colorPrimary,
                    fontFamily: fontBold,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).marginSymmetric(horizontal: 12.w),
        ],
      ).paddingSymmetric(
        vertical: 12.h,
      ),
    );
  }
}
