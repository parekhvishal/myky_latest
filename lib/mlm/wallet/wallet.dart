import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../widget/paginated_list.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String? type;

  @override
  void initState() {
    type = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Transactions'),
        automaticallyImplyLeading: type != null ? true : false,
      ),
      body: PaginatedList(
        apiFuture: (int page) async {
          return Api.http.get("member/wallet-transaction?page=$page");
        },
        listItemBuilder: _walletBuilder,
        resetStateOnRefresh: true,
        isPullToRefresh: true,
        listWithoutAppbar: true,
        noDataTitle: "Wallet Transactions",
      ),
    );
  }

  Widget _walletBuilder(dynamic item, int index) {
    return WalletListCard(wallet: item);
  }
}

class WalletListCard extends StatelessWidget {
  final dynamic wallet;

  const WalletListCard({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDebit = wallet['type'] == "Debit";
    final Color primaryColor =
    isDebit ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final Color bgColor =
    isDebit ? const Color(0xFFFFE5E5) : const Color(0xFFE0F9F7);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top colored bar
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wallet Transaction',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            wallet['date'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9E9E9E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        wallet['type'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Divider
                Container(
                  height: 1,
                  color: const Color(0xFFF0F0F0),
                ),
                const SizedBox(height: 16),
                // Amount Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountInfo(
                      'Total Amount',
                      '₹${wallet['amount']}',
                      Icons.account_balance_wallet_rounded,
                      const Color(0xFF5B59FC),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: const Color(0xFFF0F0F0),
                    ),
                    _buildAmountInfo(
                      'Net Amount',
                      '₹${wallet['total']}',
                      Icons.paid_rounded,
                      primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Admin Charge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: const Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Admin Charge',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B6B6B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${wallet['adminCharge']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInfo(
      String label,
      String amount,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
