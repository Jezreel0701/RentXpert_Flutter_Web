import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final landlordsColor = const Color(0xFF3D4C73);
  final tenantsColor = const Color(0xFF8FA3B0);
  final apartmentColor = const Color(0xFF4E62B3);
  final dormColor = const Color(0xFF6D6D6D);
  final boardingColor = const Color(0xFF60C2F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reports & Analytics",
                style: TextStyle(
                  fontSize: 45,
                  fontFamily: "Inter",
                  color: Color(0xFF4F768E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      ["Boarding houses", "Dorms", "Apartments"],
                      [69.72, 64.25, 124.25],
                      [boardingColor, dormColor, apartmentColor],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // New Bar Chart with Dropdown
              _BarChartWithYearSelector(
                title: "Engagement Metrics",
                yearData: {
                  "2024": 30,
                  "2025": 60,
                  "2026": 100,
                  "2027": 80,
                  "2028": 95,
                  "2029": 105,
                  "2030": 120,
                  "2031": 110,
                  "2032": 150,
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pie Chart
  Widget _buildPieChart(String title, List<String> labels, List<double> values, List<Color> colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 390;

        double chartRadius = isSmallScreen ? 80 : 120;

        return Column(
          children: [
            Container(
              height: isSmallScreen ? 220 : 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                          sections: List.generate(values.length, (i) {
                            return PieChartSectionData(
                              value: values[i],
                              color: colors[i],
                              radius: chartRadius,
                              title: '${labels[i]}\n${values[i].toStringAsFixed(2)}',
                              titleStyle: const TextStyle(
                                fontFamily: "Inter",
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
                  ),

                  if (!isSmallScreen) ...[
                    const SizedBox(width: 12),
                    // Legend
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(labels.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colors[index],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  labels[index],
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ]
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
      },
    );
  }

  // Donut Chart
  Widget _buildDonutChart(String title, List<String> labels, List<double> values, List<Color> colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 430;
        double total = values.reduce((a, b) => a + b);

        // Dynamically adjust chart size and font
        double chartRadius = isSmallScreen ? 60 : 80;
        double centerSpaceRadius = isSmallScreen ? 30 : 40;

        double fontSizeForTitle(double chartWidth) {
          if (chartWidth < 200) {
            return 8;
          } else if (chartWidth < 300) {
            return 10;
          } else {
            return 12;
          }
        }

        return Column(
          children: [
            Container(
              height: isSmallScreen ? 220 : 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  // Donut Chart
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: centerSpaceRadius,
                              sections: List.generate(values.length, (i) {
                                double ratio = values[i] / total;
                                double fontSize = fontSizeForTitle(constraints.maxWidth);
                                double titleOffset = ratio >= 0.1 ? 0.6 : 0.7;

                                String sectionTitle = ratio >= 0.1
                                    ? '${labels[i]}\n${values[i].toStringAsFixed(2)}'
                                    : '${values[i].toStringAsFixed(2)}';

                                return PieChartSectionData(
                                  value: values[i],
                                  color: colors[i],
                                  radius: chartRadius,
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
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (!isSmallScreen) ...[
                    const SizedBox(width: 12),
                    // Legend
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(labels.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colors[index],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  labels[index],
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ]
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
      },
    );
  }

}

//  New Stateful BarChart Widget
class _BarChartWithYearSelector extends StatefulWidget {
  final String title;
  final Map<String, double> yearData;

  const _BarChartWithYearSelector({required this.title, required this.yearData});

  @override
  State<_BarChartWithYearSelector> createState() => _BarChartWithYearSelectorState();
}

class _BarChartWithYearSelectorState extends State<_BarChartWithYearSelector> {
  late String startYear;
  late String endYear;

  @override
  void initState() {
    super.initState();
    final years = widget.yearData.keys.toList()..sort();
    startYear = years.first;
    endYear = years.last;
  }

  List<String> getSelectedYears() {
    int start = int.parse(startYear);
    int end = int.parse(endYear);
    int mid = start + ((end - start) ~/ 2);
    return [start.toString(), mid.toString(), end.toString()];
  }

  @override
  Widget build(BuildContext context) {
    final allYears = widget.yearData.keys.toList()..sort();
    final selectedYears = getSelectedYears();
    final selectedData = selectedYears.map((y) => widget.yearData[y] ?? 0).toList();

    final List<Color> barColors = [
      const Color(0xFFA0BACB),
      const Color(0xFF5E636F),
      const Color(0xFF848FB1),
    ];

    return Center(
      child: Column(
        children: [
          Container(
            height: 300,
            width: 600,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Row(
              children: [
                // Dropdowns
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Start Year:",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DropdownButton<String>(
                      value: startYear,
                      onChanged: (value) {
                        setState(() => startYear = value!);
                      },
                      dropdownColor: Color(0xFFC5D9E6), // Color when the dropdown is open
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w300,
                          fontSize:  16,
                          color: Color(0xFF69769F)), // Change text color of the selected item
                      items: allYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text("End Year:",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                    ),
                    ),
                    DropdownButton<String>(
                      value: endYear,
                      onChanged: (value) {
                        setState(() => endYear = value!);
                      },
                      dropdownColor: Color(0xFFC5D9E6), // Color when the dropdown is open
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w300,
                          fontSize:  16,
                          color: Color(0xFF69769F) // Change text color of the selected item
                      ),
                      items: allYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                    ),
                  ],
                ),
                const SizedBox(width: 20),

                //  Bar Chart
                Expanded(
                  child: Column(
                    children: [
                      // Bar Chart
                      Expanded(
                        child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.center,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: Color(0xFFC5D9E6),
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${selectedYears[group.x]}: ${rod.toY}',
                                      const TextStyle(
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF69769F),
                                      ),
                                    );
                                  },
                                ),
                                touchCallback: (event, response) {
                                  setState(() {}); // Trigger rebuild on hover
                                },
                              ),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(selectedData.length, (i) {
                                final isTouched = i == (BarTouchData().touchTooltipData?.tooltipBgColor ?? -1); // fallback
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      fromY: 0,
                                      toY: selectedData[i],
                                      width: 70,
                                      color: isTouched ? Colors.orangeAccent : barColors[i],
                                      borderRadius: BorderRadius.circular(2),
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                      ),

                      const SizedBox(height: 12),

                      // Custom Text Below Bars
                      Padding(
                        padding: const EdgeInsets.only(left: 45.0),
                        child: const Text(
                          'Users Growth report per year',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Year Labels Below Text
                      Padding(
                        padding: const EdgeInsets.only(left: 45.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: selectedYears.map((year) {
                            return Container(
                              width: 70, // Adjust this width as needed
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 4), // Small gap between labels
                              child: Text(
                                year,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),


                    ],
                  ),
                ),


              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }


}
