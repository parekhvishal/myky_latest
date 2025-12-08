// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:nb_utils/nb_utils.dart';
//
// import '../../../../widget/theme.dart';
// import '../../../services/size_config.dart';
//
// class DayWiseDownLineGraph extends StatefulWidget {
//   final String? title;
//   final List? dayWiseDownLine;
//
//   const DayWiseDownLineGraph({
//     @required this.title,
//     @required this.dayWiseDownLine,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _DayWiseDownLineGraphState createState() => _DayWiseDownLineGraphState();
// }
//
// class _DayWiseDownLineGraphState extends State<DayWiseDownLineGraph> {
//   final Color barBackgroundColor = colorPrimary;
//   final Duration animDuration = const Duration(milliseconds: 250);
//
//   int touchedIndex = -1;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(
//         horizontal: 15,
//       ),
//       decoration: boxDecoration(
//         radius: 5,
//         showShadow: true,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           5.height,
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10),
//             child: text(
//               widget.title!,
//               textColor: black,
//               fontFamily: fontBold,
//             ),
//           ),
//           // 10.height,
//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.center,
//           //   crossAxisAlignment: CrossAxisAlignment.center,
//           //   children: [
//           //     Container(
//           //       width: 20,
//           //       decoration: BoxDecoration(
//           //           border: Border.all(
//           //         color: colorPrimary,
//           //         width: 2.5,
//           //       )),
//           //     ),
//           //     8.width,
//           //     text('Daily Downline'),
//           //   ],
//           // ),
//           // 10.height,
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 Container(
//                   width: w(100),
//                   height: h(50),
//                   padding: EdgeInsets.only(
//                     // top: 50,
//                     bottom: 20,
//                     right: 50,
//                   ),
//                   child: BarChart(
//                     BarChartData(
//                       gridData: FlGridData(
//                         show: false,
//                       ),
//                       axisTitleData: FlAxisTitleData(
//                         topTitle: AxisTitle(
//                           showTitle: true,
//                           margin: 20,
//                           reservedSize: 50,
//                           titleText: '',
//                           textStyle: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         leftTitle: AxisTitle(
//                           showTitle: true,
//                           margin: -10,
//                           reservedSize: 30,
//                           titleText: 'Members',
//                           textStyle: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         bottomTitle: AxisTitle(
//                             showTitle: true,
//                             titleText: 'Date',
//                             textStyle: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                             textAlign: TextAlign.center,
//                             reservedSize: 10,
//                             margin: 40),
//                       ),
//                       titlesData: FlTitlesData(
//                         rightTitles: SideTitles(showTitles: false),
//                         topTitles: SideTitles(showTitles: false),
//                         bottomTitles: SideTitles(
//                           rotateAngle: -35,
//                           showTitles: true,
//                           getTitles: (index) {
//                             return widget.dayWiseDownLine![index.toInt()]['day'].toString();
//                           },
//                           getTextStyles: (context, index) {
//                             return TextStyle(fontSize: 11, color: Colors.black);
//                           },
//                         ),
//                       ),
//                       borderData: FlBorderData(
//                           border: Border(
//                         top: BorderSide.none,
//                         right: BorderSide.none,
//                         left: BorderSide(width: 1),
//                         bottom: BorderSide(width: 1),
//                       )),
//                       groupsSpace: 10,
//                       barGroups: widget.dayWiseDownLine!
//                           .asMap()
//                           .map(
//                             (index, element) {
//                               return MapEntry(
//                                 index,
//                                 BarChartGroupData(
//                                   x: index,
//                                   barRods: [
//                                     BarChartRodData(
//                                         y: double.parse(
//                                           element['count'].toString(),
//                                         ),
//                                         width: 20,
//                                         colors: [teal])
//                                   ],
//                                 ),
//                               );
//                             },
//                           )
//                           .values
//                           .toList(),
//                       barTouchData: BarTouchData(
//                         touchTooltipData: BarTouchTooltipData(
//                             tooltipBgColor: Colors.blueGrey,
//                             getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                               return BarTooltipItem(
//                                 widget.dayWiseDownLine![group.x.toInt()]['day'] + '\n',
//                                 const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                                 children: <TextSpan>[
//                                   TextSpan(
//                                     text: "${rod.y.toInt().toString()}",
//                                     style: const TextStyle(
//                                       color: Colors.yellow,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<BarChartGroupData> showingGroups() => List.generate(widget.dayWiseDownLine!.length, (i) {
//         return makeGroupData(i, widget.dayWiseDownLine![i]['count'].toDouble(),
//             isTouched: i == touchedIndex);
//       });
//
//   BarChartGroupData makeGroupData(
//     int x,
//     double y, {
//     bool isTouched = false,
//     Color barColor = orange,
//     double width = 22,
//     List<int> showTooltips = const [],
//   }) {
//     return BarChartGroupData(
//       x: x,
//       barRods: [
//         BarChartRodData(
//           y: isTouched ? y + 1 : y,
//           colors: isTouched ? [colorPrimary] : [barColor],
//           width: width,
//           borderSide: isTouched
//               ? BorderSide(color: colorPrimary, width: 1)
//               : const BorderSide(color: Colors.white, width: 0),
//           backDrawRodData: BackgroundBarChartRodData(
//             show: true,
//             y: widget.dayWiseDownLine!.length.toDouble(),
//             colors: [barBackgroundColor],
//           ),
//         ),
//       ],
//       showingTooltipIndicators: showTooltips,
//     );
//   }
// }
