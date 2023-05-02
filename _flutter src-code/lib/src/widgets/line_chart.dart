import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';

import '../model/attendance_model.dart';

class DashboardLineChart extends StatelessWidget {
  final FacultyController _dataController;
  const DashboardLineChart(
      {super.key,
      required this.isShowingMainData,
      required FacultyController facultyController})
      : _dataController = facultyController;
  final bool isShowingMainData;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData2,
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        minX: 1,
        maxX: 6,
        maxY: 10,
        minY: 1,
      );

  LineTouchData get lineTouchData2 => LineTouchData(
        enabled: false,
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData2 => [
        getLineChartBarAbsent(),
        getLineChartBarOnTime(),
        getLineChartBarLate(),
        getLineChartBarCutting(),
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    List<int> countPercentile = _dataController.getPercentileCounts();
    const style = TextStyle(
      fontSize: 14,
      color: Colors.grey,
    );
    String text = '';
    if (countPercentile[0] == value.toInt()) {
      text = countPercentile[0].toString();
    } else if (countPercentile[1] == value.toInt()) {
      text = countPercentile[1].toString();
    } else if (countPercentile[2] == value.toInt()) {
      text = countPercentile[2].toString();
    } else if (countPercentile[3] == value.toInt()) {
      text = countPercentile[3].toString();
    } else if (countPercentile[4] == value.toInt()) {
      text = countPercentile[4].toString();
      // } else if (countPercentile[5] == value.toInt()) {
      //   text = countPercentile[5].toString();
    } else {
      text = '';
    }

    // switch (value.toInt()) {
    //   case 1:
    //     text = countPercentile[0].toString();
    //     break;
    //   case 2:
    //     text = countPercentile[1].toString();
    //     break;
    //   case 3:
    //     text = countPercentile[2].toString();
    //     break;
    //   case 4:
    //     text = countPercentile[3].toString();
    //     break;
    //   case 5:
    //     text = countPercentile[4].toString();
    //     break;
    //   case 10:
    //     text = countPercentile[4].toString();
    //     break;
    //   default:
    //     return Container();
    // }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 35,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    List<String> dateRangeList = _dataController.formattedDateRangeList;
    const style = TextStyle(
      fontSize: 14,
      color: Colors.grey,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text(dateRangeList[0], style: style);
        break;
      case 2:
        text = Text(
            dateRangeList[0] == dateRangeList[1] ? '' : dateRangeList[1],
            style: style);
        break;
      case 3:
        text = Text(
            dateRangeList[1] == dateRangeList[2] ? '' : dateRangeList[2],
            style: style);
        break;
      case 4:
        text = Text(
            dateRangeList[2] == dateRangeList[3] ? '' : dateRangeList[3],
            style: style);
        break;
      case 5:
        text = Text(
            dateRangeList[3] == dateRangeList[4] ? '' : dateRangeList[4],
            style: style);
        break;
      case 6:
        text = Text(
            dateRangeList[4] == dateRangeList[5] ? '' : dateRangeList[5],
            style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0), child: text),
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 25,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.transparent),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData getLineChartBarAbsent() {
    List<double> absentListCount =
        _dataController.getCountOfRemark(Remarks.absent);
    print('getLineChartBarData2_1');
    print(absentListCount);
    print(absentListCount.length);
    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: Colors.red.withOpacity(0.5),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: [
        FlSpot(1, absentListCount[0]),
        FlSpot(2, absentListCount[1]),
        FlSpot(3, absentListCount[2]),
        FlSpot(4, absentListCount[3]),
        FlSpot(5, absentListCount[4]),
        FlSpot(6, absentListCount[5]),
      ],
    );
  }

  LineChartBarData getLineChartBarOnTime() {
    List<double> onTimeListCount =
        _dataController.getCountOfRemark(Remarks.onTime);
    print('getLineChartBarData2_1');
    print(onTimeListCount);
    print(onTimeListCount.length);
    return LineChartBarData(
      isCurved: true,
      color: Colors.green.withOpacity(0.5),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.green.withOpacity(0.2),
      ),
      spots: [
        FlSpot(1, onTimeListCount[0]),
        FlSpot(2, onTimeListCount[1]),
        FlSpot(3, onTimeListCount[2]),
        FlSpot(4, onTimeListCount[3]),
        FlSpot(5, onTimeListCount[4]),
        FlSpot(6, onTimeListCount[5]),
      ],
    );
  }

  LineChartBarData getLineChartBarLate() {
    List<double> lateListCount = _dataController.getCountOfRemark(Remarks.late);

    print(lateListCount);
    print(lateListCount.length);
    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: Colors.orange,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: [
        FlSpot(1, lateListCount[0]),
        FlSpot(2, lateListCount[1]),
        FlSpot(3, lateListCount[2]),
        FlSpot(4, lateListCount[3]),
        FlSpot(5, lateListCount[4]),
        FlSpot(6, lateListCount[5]),
      ],
    );
  }

  LineChartBarData getLineChartBarCutting() {
    List<double> cuttingListCount =
        _dataController.getCountOfRemark(Remarks.cutting);

    print(cuttingListCount);
    print(cuttingListCount.length);
    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: Colors.yellow.shade700,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: [
        FlSpot(1, cuttingListCount[0]),
        FlSpot(2, cuttingListCount[1]),
        FlSpot(3, cuttingListCount[2]),
        FlSpot(4, cuttingListCount[3]),
        FlSpot(5, cuttingListCount[4]),
        FlSpot(6, cuttingListCount[5]),
      ],
    );
  }
}
