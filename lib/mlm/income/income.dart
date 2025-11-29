import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';
import '../common_list.dart';

class Incomes extends StatefulWidget {
  @override
  _IncomesState createState() => _IncomesState();
}

class _IncomesState extends State<Incomes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 2.0, title: const Text('Rewards')),
      body: SafeArea(
        child: DefaultTabController(
          length: 7,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: Colors.white,
                child: SafeArea(
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
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'Offline Store Rewards',
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: fontBold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'Online Store Rewards',
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: fontBold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'Self Purchase Cashback',
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: fontBold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'Shops Sales Share',
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: fontBold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'Share & Earn Rewards',
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: fontBold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              child: const Text(
                                'Recharge cashback',
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: fontBold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'DTH cashback',
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
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                PaginatedList(
                  noDataTitle: 'Offline Store Rewards',
                  apiFuture: (int page) async {
                    return Api.http
                        .get("member/incomes/offline-store-income?page=$page");
                  },
                  listItemBuilder: _offlineStoreIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Online Store Rewards',
                  apiFuture: (int page) async {
                    return Api.http
                        .get("member/incomes/online-store-income?page=$page");
                  },
                  listItemBuilder: _onlineStoreIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Self Purchase Rewards',
                  apiFuture: (int page) async {
                    return Api.http.get(
                        "member/incomes/self-purchase-discount?page=$page");
                  },
                  listItemBuilder: _selfPurchaseIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Shop Sales Share',
                  apiFuture: (int page) async {
                    return Api.http
                        .get("member/incomes/shop-sponsor-income?page=$page");
                  },
                  listItemBuilder: _salesProfitIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Share & Earn Rewards',
                  apiFuture: (int page) async {
                    return Api.http
                        .get("member/incomes/share-and-earn-income?page=$page");
                  },
                  listItemBuilder: _shareEarnIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Mobile Recharge Rewards',
                  apiFuture: (int page) async {
                    return Api.http.get(
                        "member/incomes/mobile-recharge-income?page=$page");
                  },
                  listItemBuilder: _mobileRechargeIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'DTH Recharge Rewards',
                  apiFuture: (int page) async {
                    return Api.http
                        .get("member/incomes/dth-recharge-income?page=$page");
                  },
                  listItemBuilder: _dthRechargeBuilder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileRechargeIncomeBuilder(dynamic income, int index) {
    return IncomeListCard(
      data: income,
      title: "Mobile Recharge Cashback",
      subtitle: "Earned from recharge commission",
      color: Colors.green,
    );
  }

  Widget _dthRechargeBuilder(dynamic income, int index) {
    return IncomeListCard(
      data: income,
      title: "DTH Recharge Cashback",
      subtitle: "Earned from DTH recharge",
      color: Colors.redAccent,
    );
  }

  Widget _offlineStoreIncomeBuilder(dynamic income, int index) {
    return IncomeListCard(
      data: income,
      title: "Offline Store Reward",
      subtitle: "Earned from store purchase",
      color: Colors.deepPurpleAccent,
    );
  }

  Widget _onlineStoreIncomeBuilder(dynamic income, int index) {
    return IncomeListCard(
      data: income,
      title: "Online Store Reward",
      subtitle: "Earned from online order",
      color: Colors.blueAccent,
    );
  }

  Widget _shareEarnIncomeBuilder(dynamic income, int index) {
    return IncomeListCard(
      data: income,
      title: "Share & Earn Reward",
      subtitle: "Referral-based earning",
      color: Colors.pinkAccent,
    );
  }

  Widget _promotorSponsorIncomeBuilder(dynamic promoterIncome, int index) {
    return Container(
      width: w(80),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: white,
        radius: 10.0,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 7.5,
        vertical: 7.5,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CircleAvatar(
                          backgroundColor: colorPrimary.withOpacity(0.2),
                          radius: 20,
                          child: Icon(
                            UniconsLine.rupee_sign,
                            color: colorPrimary,
                            size: textSizeXLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: w(4)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          const SizedBox(
                            height: 5,
                          ),
                          text(
                            promoterIncome['createdAt'],
                            fontFamily: fontBold,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      text(
                        "Amount (₹) :",
                        fontFamily: fontBold,
                      ),
                      text(
                        promoterIncome['amount'],
                        textColor: textColorSecondary,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      text(
                        "TDS (₹) :",
                        fontFamily: fontBold,
                      ),
                      text(
                        promoterIncome['tds'],
                        textColor: textColorSecondary,
                        fontSize: textSizeSMedium,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      text(
                        "Total (₹) :",
                        fontFamily: fontBold,
                      ),
                      const SizedBox(height: 4),
                      text(
                        promoterIncome['total'],
                        textColor: textColorSecondary,
                      ),
                    ],
                  ),
                  // Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      text(
                        "Remark :",
                        fontFamily: fontBold,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: text(
                          promoterIncome['comment'],
                          textColor: textColorSecondary,
                          isLongText: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selfPurchaseIncomeBuilder(dynamic income, int index) {
    return IncomeListCard(
      data: income,
      title: "Self Purchase Cashback",
      subtitle: "Your direct cashback",
      color: Colors.teal,
    );
  }

  Widget _salesProfitIncomeBuilder(dynamic income, int index) {
    return IncomeListCard(
      data: income,
      title: "Shop Sales Share",
      subtitle: "Profit share from store sales",
      color: Colors.orangeAccent,
    );
  }
}


class IncomeListCard extends StatelessWidget {
  final dynamic data;
  final String title;
  final String subtitle;
  final Color color;

  const IncomeListCard({
    Key? key,
    required this.data,
    required this.title,
    required this.subtitle,
    this.color = Colors.blueAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle missing keys gracefully
    String amount = (data['amount'] ?? '0').toString();
    String adminCharge = (data['adminCharge'] ?? data['tds'] ?? '0').toString();
    String total = (data['total'] ?? '0').toString();
    String date = (data['createdAt'] ?? '').toString();
    String remark = (data['comment'] ?? '').toString();

    return CommonListCard(
      data: data,
      title: title,
      subtitle: subtitle,
      status: date,
      statusColor: color,
      icon: UniconsLine.rupee_sign,
      borderRadius: 20,
      showShadow: true,
      infoRows: [
        InfoRow(
          leftTitle: "Amount (₹)",
          leftValue: amount,
          rightTitle: "Admin Charge / TDS (₹)",
          rightValue: adminCharge,
        ),
        InfoRow(
          leftTitle: "Net / Total (₹)",
          leftValue: total,
          rightTitle: "Remark",
          rightValue: remark.isEmpty ? '-' : remark,
        ),
      ],
    );
  }
}
