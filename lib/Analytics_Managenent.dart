import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final landlordsColor = const Color(0xFF3D4C73); // dark blue
  final tenantsColor = const Color(0xFF8FA3B0); // soft blue-grey
  final apartmentColor = const Color(0xFF4E62B3); // bluish
  final dormColor = const Color(0xFF6D6D6D); // dark grey
  final boardingColor = const Color(0xFF60C2F0); // sky blue

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reports & Analytics",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildPieChart(
                      "Total Users",
                      ["Landlords", "Tenants"],
                      [159.59, 118.37],
                      [landlordsColor, tenantsColor],
                    ),
                  ),
                  const SizedBox(width: 24),

                  Expanded(
                    child: _buildDonutChart(
                      "Listed Properties",
                      ["boarding houses", "dorms", "apartments"],
                      [69.72, 64.25, 124.25],
                      [boardingColor, dormColor, apartmentColor],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildBarChart(
                "Engagement Metrics",
                ["2024", "2025", "2026"],
                [30, 60, 90],
                barColor: const Color(0xFF9DA2A5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(String title, List<String> labels, List<double> values,
      List<Color> colors) {
    return Column(
      children: [
        Container(
          height: 230,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: List.generate(values.length, (i) {
                // For two segments (total users) we always show both label and value.
                return PieChartSectionData(
                  value: values[i],
                  color: colors[i],
                  radius: 90,
                  title: '${labels[i]}\n${values[i].toStringAsFixed(2)}',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  titlePositionPercentageOffset: 0.6,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart(String title, List<String> labels,
      List<double> values, List<Color> colors) {
    double total = values.reduce((a, b) => a + b);
    const double labelThreshold = 0.1; // 10% threshold

    return Column(
      children: [
        Container(
          height: 280, // increased from 260
          padding: const EdgeInsets.all(12), // slightly reduced padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 48,
                  sections: List.generate(values.length, (i) {
                    double ratio = values[i] / total;
                    double fontSize = ratio >= 0.15 ? 11 : 9;
                    double titleOffset = ratio >= labelThreshold ? 0.6 : 0.7;

                    String sectionTitle = ratio >= labelThreshold
                        ? '${labels[i]}\n${values[i].toStringAsFixed(2)}'
                        : '${values[i].toStringAsFixed(2)}';

                    return PieChartSectionData(
                      value: values[i],
                      color: colors[i],
                      radius: 80, // reduced from 90 to give more room
                      title: sectionTitle,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: titleOffset,
                    );
                  }),
                ),
              ),
              Text(
                total.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }


  Widget _buildBarChart(String title, List<String> years, List<double> data,
      {required Color barColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < years.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            years[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(data.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      fromY: 0,
                      toY: data[i],
                      width: 26,
                      color: barColor,
                      borderRadius: BorderRadius.circular(6),
                    )
                  ],
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
