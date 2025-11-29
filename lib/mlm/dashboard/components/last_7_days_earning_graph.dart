// import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../widget/theme.dart';
import '../../../services/size_config.dart';

class DayWiseEarningGraph extends StatefulWidget {
  final String? title;
  final List? dayWiseEarning;

  const DayWiseEarningGraph({
    @required this.title,
    @required this.dayWiseEarning,
    Key? key,
  }) : super(key: key);

  @override
  _DayWiseEarningGraphState createState() => _DayWiseEarningGraphState();
}

class _DayWiseEarningGraphState extends State<DayWiseEarningGraph> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: boxDecoration(
        radius: 5,
        showShadow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          5.height,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: text(
              widget.title!,
              textColor: black,
              fontFamily: fontBold,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  width: w(98),
                  height: h(55),
                  padding: EdgeInsets.only(
                    bottom: 20,
                    right: 50,
                  ),
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueAccent,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;

                              return LineTooltipItem(
                                '${widget.dayWiseEarning![flSpot.x.toInt()]['day']} \n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: "${flSpot.y.toDouble().toString()}",
                                    style: TextStyle(
                                      color: Colors.grey[100],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: Color(0xff4e4965), width: 2),
                          left: BorderSide(color: Color(0xff4e4965), width: 2),
                          right: BorderSide(color: Colors.transparent),
                          top: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      gridData: FlGridData(
                        show: false,
                      ),
                      axisTitleData: FlAxisTitleData(
                        topTitle: AxisTitle(
                          showTitle: true,
                          margin: 20,
                          reservedSize: 50,
                          titleText: '',
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        leftTitle: AxisTitle(
                          showTitle: true,
                          margin: 0,
                          reservedSize: 20,
                          titleText: 'Amount',
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        bottomTitle: AxisTitle(
                          showTitle: true,
                          titleText: 'Date',
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          reservedSize: 0,
                          margin: 30,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        bottomTitles: SideTitles(
                          rotateAngle: -35,
                          showTitles: true,
                          getTitles: (index) {
                            return widget.dayWiseEarning![index.toInt()]['day'].toString();
                          },
                          getTextStyles: (context, index) {
                            return TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black,
                            );
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          colors: [deepPink],
                          barWidth: 3,
                          isStrokeCapRound: true,
                          preventCurveOverShooting: true,
                          spots: widget.dayWiseEarning!
                              .asMap()
                              .map(
                                (index, element) {
                                  return MapEntry(
                                    index,
                                    FlSpot(
                                      index.toDouble(),
                                      double.parse(
                                        element['amount'].toString(),
                                      ),
                                    ),
                                  );
                                },
                              )
                              .values
                              .toList(),
                          isCurved: true,
                          dotData: FlDotData(
                            show: true,
                          ),
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
