import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';
import '../common_list.dart';
import 'common_wallet_display.dart';

class PendingWallet extends StatefulWidget {
  @override
  _PendingWalletState createState() => _PendingWalletState();
}

class _PendingWalletState extends State<PendingWallet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Wallet Transactions'),
      ),
      body: PaginatedList(
        apiFuture: (int page) async {
          return Api.http.get("member/pending-wallet-transaction?page=$page");
        },
        listItemBuilder: _walletBuilder,
        resetStateOnRefresh: true,
        isPullToRefresh: true,
        listWithoutAppbar: true,
        noDataTitle: "Pending Wallet Transactions",
      ),
    );
  }

  Widget _walletBuilder(dynamic item, int index) {
    return PendingWalletListCard(item: item);
  }


  // Widget _walletBuilder(dynamic item, int index) {
  //   return Container(
  //     decoration: boxDecoration(radius: 10, showShadow: true),
  //     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: <Widget>[
  //             Row(
  //               children: <Widget>[
  //                 CircleAvatar(
  //                   backgroundColor: colorPrimary.withOpacity(0.2),
  //                   radius: 20,
  //                   child: Icon(
  //                     Icons.account_balance_wallet,
  //                     color: colorPrimary,
  //                     size: 20,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Text(
  //                   item['date'],
  //                   style: const TextStyle(
  //                     color: Colors.black38,
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //               decoration: BoxDecoration(
  //                 color: item['type'] == "Debit" ? Colors.red : Colors.green,
  //                 borderRadius: const BorderRadius.all(Radius.circular(5)),
  //               ),
  //               child: text(
  //                 item['type'],
  //                 textColor: white,
  //                 textAllCaps: true,
  //                 fontFamily: fontSemibold,
  //                 fontSize: textSizeSMedium,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: <Widget>[
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: <Widget>[
  //                 text(
  //                   "Total Amount",
  //                   fontFamily: fontSemibold,
  //                   fontSize: textSizeSMedium,
  //                 ),
  //                 Row(
  //                   children: [
  //                     text(
  //                       '₹ ${item['amount']}'.toString(),
  //                       textColor:
  //                           item['type'] == "Debit" ? Colors.red : Colors.green,
  //                       fontFamily: fontBold,
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: <Widget>[
  //                 text(
  //                   "Net Amount",
  //                   fontFamily: fontSemibold,
  //                   fontSize: textSizeSMedium,
  //                 ),
  //                 Row(
  //                   children: [
  //                     text(
  //                       '₹ ${item['total']}'.toString(),
  //                       textColor: colorPrimary,
  //                       fontFamily: fontBold,
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: <Widget>[
  //                 text(
  //                   "Admin Charge",
  //                   fontFamily: fontSemibold,
  //                   fontSize: textSizeSMedium,
  //                 ),
  //                 text(
  //                   '₹ ${item['adminCharge']}'.toString(),
  //                   textColor: textColorSecondary,
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(width: 10),
  //           ],
  //         ),
  //         // Divider(height: 25),
  //         // Column(
  //         //   children: <Widget>[
  //         //     RichText(
  //         //       text: TextSpan(
  //         //         children: [
  //         //           TextSpan(
  //         //             text: 'Remark : ',
  //         //             style: TextStyle(
  //         //               fontSize: textSizeSMedium,
  //         //               color: colorPrimary,
  //         //               fontFamily: fontSemibold,
  //         //             ),
  //         //           ),
  //         //           TextSpan(
  //         //             text: item['remark'],
  //         //             style: TextStyle(
  //         //               fontSize: textSizeSMedium,
  //         //               color: textColorSecondary,
  //         //             ),
  //         //           )
  //         //         ],
  //         //       ),
  //         //     ),
  //         //   ],
  //         // ),
  //       ],
  //     ),
  //   );
  // }
}

class PendingWalletListCard extends StatelessWidget {
  final dynamic item;

  const PendingWalletListCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDebit = item['type'] == "Debit";
    final Color typeColor =
    isDebit ? Colors.redAccent.shade200 : Colors.greenAccent.shade700;

    return DataDisplayCard(
      data: item,
      title: "Pending Wallet Transaction",
      subtitle: "Status: Awaiting Confirmation",
      status: item['date'] ?? '',
      icon: UniconsLine.hourglass,
      statusColor: typeColor,
      infoRows: [
        InfoRow(
          leftTitle: "Total Amount (₹)",
          leftValue: item['amount']?.toString() ?? '0',
          rightTitle: "Net Amount (₹)",
          rightValue: item['total']?.toString() ?? '0',
        ),
        InfoRow(
          leftTitle: "Admin Charge (₹)",
          leftValue: item['adminCharge']?.toString() ?? '0',
          rightTitle: "Transaction Type",
          rightValue: item['type']?.toString() ?? 'N/A',
        ),
      ],
    );
  }
}
