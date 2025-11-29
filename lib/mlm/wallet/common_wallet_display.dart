import 'package:flutter/material.dart';
import '../common_list.dart';

/// A universal card widget that can adapt to any structured data set.
/// Ideal for Wallet, Incomes, Payouts, etc.
class DataDisplayCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  final String subtitle;
  final String status; // Usually a date or identifier
  final IconData icon;
  final Color statusColor;
  final List<InfoRow> infoRows;

  const DataDisplayCard({
    Key? key,
    required this.data,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.statusColor,
    required this.infoRows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonListCard(
      data: data,
      title: title,
      subtitle: subtitle,
      status: status,
      statusColor: statusColor,
      icon: icon,
      infoRows: infoRows,
      borderRadius: 20,
    );
  }
}
