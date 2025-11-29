import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';
import '../common_list.dart';
import 'common_wallet_display.dart';

class CoinWallet extends StatefulWidget {
  const CoinWallet({super.key});

  @override
  CoinWalletState createState() => CoinWalletState();
}

class CoinWalletState extends State<CoinWallet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Wallet Transactions'),
      ),
      body: PaginatedList(
        apiFuture: (int page) async {
          return Api.http.get("member/coin-wallet-transaction?page=$page");
        },
        listItemBuilder: _promoterWalletBuilder,
        resetStateOnRefresh: true,
        isPullToRefresh: true,
        listWithoutAppbar: true,
        noDataTitle: "Coin Wallet Transactions",
      ),
    );
  }

  Widget _promoterWalletBuilder(dynamic item, int index) {
    return CoinWalletListCard(item: item);
  }


// Widget _promoterWalletBuilder(dynamic item, int index) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Colors.white, Colors.grey.shade50],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               children: [
  //                 Text(
  //                   item['date'] ?? 'N/A',
  //                   style: TextStyle(
  //                     color: Colors.grey.shade600,
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 14,
  //                     letterSpacing: 0.5,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             // Transaction Type Badge
  //             Container(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: item['type'] == "Debit"
  //                     ? Colors.red.shade400
  //                     : Colors.green.shade400,
  //                 borderRadius: BorderRadius.circular(8),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 4,
  //                     offset: const Offset(0, 2),
  //                   ),
  //                 ],
  //               ),
  //               child: Text(
  //                 item['type']?.toUpperCase() ?? 'N/A',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.w700,
  //                   fontSize: 12,
  //                   letterSpacing: 0.5,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         // Transaction Details
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             // Total Coins
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   "Earned Coins",
  //                   style: TextStyle(
  //                     color: Colors.grey.shade700,
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Row(
  //                   children: [
  //                     Image.asset(
  //                       'assets/images/myky.png',
  //                       height: 20,
  //                       width: 20,
  //                       fit: BoxFit.contain,
  //                     ),
  //                     const SizedBox(width: 6),
  //                     Text(
  //                       '${item['amount'] ?? 0}',
  //                       style: TextStyle(
  //                         color: item['type'] == "Debit"
  //                             ? Colors.red.shade600
  //                             : colorPrimary,
  //                         fontWeight: FontWeight.w700,
  //                         fontSize: 18,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class CoinWalletListCard extends StatelessWidget {
  final dynamic item;

  const CoinWalletListCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDebit = item['type'] == "Debit";
    final Color typeColor =
    isDebit ? Colors.redAccent.shade200 : Colors.greenAccent.shade700;

    return DataDisplayCard(
      data: item,
      title: "Coin Wallet Transaction",
      subtitle: "Transaction Type: ${item['type'] ?? 'N/A'}",
      status: item['date'] ?? '',
      icon: UniconsLine.coins,
      statusColor: typeColor,
      infoRows: [
        InfoRow(
          leftTitle: "Earned Coins",
          leftValue: "${item['amount'] ?? '0'}",
          rightTitle: "Transaction Type",
          rightValue: item['type'] ?? 'N/A',
        ),
      ],
    );
  }
}

