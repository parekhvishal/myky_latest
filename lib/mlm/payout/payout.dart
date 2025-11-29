import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';
import '../common_list.dart';

class Payout extends StatefulWidget {
  @override
  _PayoutState createState() => _PayoutState();
}

class _PayoutState extends State<Payout> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: 'Payouts',
      apiFuture: (int page) async {
        return Api.http.get("member/payouts?page=$page");
      },
      listItemBuilder: _payoutBuilder,
      resetStateOnRefresh: true,
    );
  }

  Widget _payoutBuilder(dynamic payout, int index) {
    return PayoutListCard(payout: payout);
  }
}


class PayoutListCard extends StatelessWidget {
  final dynamic payout;

  const PayoutListCard({
    Key? key,
    required this.payout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String date = (payout['createdAt'] ?? '').toString();

    return CommonListCard(
      data: payout,
      title: "Payout Summary",
      subtitle: "Detailed breakdown of earnings",
      status: date,
      statusColor: Colors.indigoAccent,
      icon: UniconsLine.money_bill,
      borderRadius: 20,
      infoRows: [
        InfoRow(
          leftTitle: "Mobile Recharge (₹)",
          leftValue: _v('mobileRechargeIncome'),
          rightTitle: "DTH Income (₹)",
          rightValue: _v('dthRechargeIncome'),
        ),
        InfoRow(
          leftTitle: "Offline Store (₹)",
          leftValue: _v('offlineStoreIncome'),
          rightTitle: "Online Store (₹)",
          rightValue: _v('onlineStoreIncome'),
        ),
        InfoRow(
          leftTitle: "Share & Earn (₹)",
          leftValue: _v('shareAndEarnIncome'),
          rightTitle: "Self Purchase (₹)",
          rightValue: _v('selfPurchaseDiscount'),
        ),
        InfoRow(
          leftTitle: "Admin Credit (₹)",
          leftValue: _v('adminCredit'),
          rightTitle: "Admin Debit (₹)",
          rightValue: _v('adminDebit'),
        ),
        InfoRow(
          leftTitle: "Amount (₹)",
          leftValue: _v('amount'),
          rightTitle: "Admin Charge (₹)",
          rightValue: _v('adminCharge'),
        ),
        InfoRow(
          leftTitle: "Gross Amount (₹)",
          leftValue: _v('grossAmount'),
          rightTitle: "TDS (₹)",
          rightValue: _v('tds'),
        ),
        InfoRow(
          leftTitle: "Payable Amount (₹)",
          leftValue: _v('payableAmount'),
          rightTitle: "Shop Sponsor (₹)",
          rightValue: _v('shopSponsorIncome'),
        ),
      ],
    );
  }

  String _v(String key) => (payout[key] ?? '0').toString();
}
