import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../../../services/auth.dart';
import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';
import '../common_list.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String? type;
  @override
  void initState() {
    type = Get.arguments;

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('length : ${Auth.isVendor()}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        automaticallyImplyLeading: type != null ? true : false,
      ),
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: Get.arguments == "myDownLine"
              ? 1
              : Get.arguments == "sales"
                  ? 3
                  : 0,
          length: Auth.user()!['code'] == "100001"
              ? 3
              : Auth.isVendor() == true
                  ? 3
                  : 2,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  child: Container(
                    // color: app_background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TabBar(
                            labelPadding:
                                const EdgeInsets.only(left: 0, right: 0),
                            indicatorWeight: 4.0,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorColor: colorPrimary,
                            labelColor: colorPrimary,
                            isScrollable: true,
                            unselectedLabelColor: textColorSecondary,
                            tabs: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                child: const Text(
                                  'My Friends',
                                  style: TextStyle(
                                      fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              if (Auth.user()!['code'] == "100001")
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    'My Patrons',
                                    style: TextStyle(
                                        fontSize: 18.0, fontFamily: fontBold),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  'TDS Report',
                                  style: TextStyle(
                                      fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              if (Auth.isVendor() == true)
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    'Sales Report',
                                    style: TextStyle(
                                        fontSize: 18.0, fontFamily: fontBold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                PaginatedList(
                  noDataTitle: 'My Friends',
                  apiFuture: (int page) async {
                    return Api.http.get("member/reports/direct?page=$page");
                  },
                  listItemBuilder: _myDirectBuilder,
                  resetStateOnRefresh: true,
                ),
                if (Auth.user()!['code'] == "100001")
                  PaginatedList(
                    noDataTitle: 'My Patrons',
                    apiFuture: (int page) async {
                      return Api.http.get("member/reports/downline?page=$page");
                    },
                    listItemBuilder: _myDownlineBuilder,
                    resetStateOnRefresh: true,
                  ),
                FutureBuilder(
                  future: Api.http.get('member/reports/tds-report').then(
                        (response) => response.data,
                      ),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.data['list'].length == 0) {
                      return Center(
                        child: Container(
                          color: white,
                          constraints: const BoxConstraints(maxWidth: 500.0),
                          height: MediaQuery.of(context).size.height,
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/no_result.png',
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fitWidth,
                              ),
                              Positioned(
                                bottom: 30,
                                left: 20,
                                right: 20,
                                child: Container(
                                  decoration: boxDecoration(
                                    radius: 10,
                                    showShadow: true,
                                    bgColor: Colors.grey[200],
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      text(
                                        'No Data Found in TDS Report',
                                        textColor: colorPrimaryDark,
                                        fontFamily: fontBold,
                                        fontSize: textSizeLargeMedium,
                                        maxLine: 2,
                                      ),
                                      const SizedBox(height: 5),
                                      text(
                                        'There was no record based on the details you entered.',
                                        isCentered: true,
                                        isLongText: true,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                    List _tdsList = snapshot.data['list'];
                    return ListView.builder(
                      itemCount: _tdsList.length,
                      itemBuilder: (context, index) {
                        return _tdsReportBuilder(_tdsList[index], index);
                      },
                    );
                  },
                ),
                if (Auth.isVendor() == true)
                  PaginatedList(
                    noDataTitle: 'Sales Reports',
                    apiFuture: (int page) async {
                      return Api.http
                          .get("member/reports/sales-report?page=$page");
                    },
                    listItemBuilder: _salesReportBuilder,
                    resetStateOnRefresh: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _myDirectBuilder(dynamic myDirect, int index) {
    return CommonListCard(
      data: myDirect,
      title: myDirect['name'],
      subtitle: myDirect['createdAt'],
      status: myDirect['status'],
      statusColor: _getStatusColor(myDirect['status']),
      icon: UniconsLine.thumbs_up,
      backgroundColor: myDirect['isPromotor'] == true
          ? Colors.green.withOpacity(0.15)
          : Colors.white,
      infoRows: [
        InfoRow(
          leftTitle: "Member ID",
          leftValue: myDirect['code'],
          rightTitle: "Parent ID",
          rightValue: myDirect['parentId'],
        ),
      ],
    );
  }
  Widget _myDownlineBuilder(dynamic myDownline, int index) {
    return CommonListCard(
      data: myDownline,
      title: myDownline['name'],
      subtitle: myDownline['createdAt'],
      status: myDownline['status'],
      statusColor: _getStatusColor(myDownline['status']),
      icon: UniconsLine.thumbs_up,
      backgroundColor: myDownline['isPromotor'] == true
          ? Colors.green.withOpacity(0.15)
          : Colors.white,
      infoRows: [
        InfoRow(
          leftTitle: "Member ID",
          leftValue: myDownline['code'],
          rightTitle: "Parent ID",
          rightValue: myDownline['parentId'],
        ),
      ],
    );
  }

  Widget _tdsReportBuilder(dynamic tdsReport, int index) {
    return CommonListCard(
      data: tdsReport,
      title: tdsReport['month'],
      subtitle: tdsReport['panCard'] ?? "N/A",
      status: "₹${tdsReport['tds']}",
      statusColor: Colors.teal,
      icon: UniconsLine.rupee_sign,
      backgroundColor: Colors.white,
      infoRows: [], // No extra rows
    );
  }
  Widget _salesReportBuilder(dynamic sales, int index) {
    return CommonListCard(
      data: sales,
      title: sales['customerName'],
      subtitle: sales['date'],
      status: "Sale",
      statusColor: Colors.orange,
      icon: UniconsLine.shopping_bag,
      backgroundColor: Colors.white,
      infoRows: [
        InfoRow(
          leftTitle: "Member ID",
          leftValue: sales['customerCode'],
          rightTitle: "Mobile",
          rightValue: sales['customerNumber'],
        ),
        InfoRow(
          leftTitle: "Amount",
          leftValue: "₹${sales['amount']}",
          rightTitle: "Profit Shared",
          rightValue: "₹${sales['companyCharge']}",
        ),
        InfoRow(
          leftTitle: "GST",
          leftValue: "₹${sales['gstAmt']}",
          rightTitle: "Payable",
          rightValue: "₹${sales['payableAmt']}",
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Free':
        return Colors.red;
      default:
        return Colors.black87;
    }
  }

}
