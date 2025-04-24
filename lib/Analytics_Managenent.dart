import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rentxpert_flutter_web/service/api.dart'; // Your API service, YearCountService, YearCount
import 'package:dropdown_button2/dropdown_button2.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Chart colors
  final landlordsColor = const Color(0xFF3D4C73);
  final tenantsColor   = const Color(0xFF8FA3B0);
  final apartmentColor = const Color(0xFF4E62B3);
  final dormColor      = const Color(0xFF6D6D6D);
  final boardingColor  = const Color(0xFF60C2F0);
  final transientColor = const Color(0xFF8FA3B0);

  // Data
  List<YearCount> yearCounts = [];
  int? landlordCount;
  int? tenantCount;
  int? boardingHouseCount;
  int? condoCount;
  int? apartmentCount;
  int? transientCount;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final l = await ApiService.fetchUserCount('Landlord');
    final t = await ApiService.fetchUserCount('Tenant');
    final a = await PropertyTypeApiService.fetchApartmentCount();
    final b = await PropertyTypeApiService.fetchBoardingHouseCount();
    final c = await PropertyTypeApiService.fetchCondoCount();
    final tr = await PropertyTypeApiService.fetchTransientCount();
    await YearCountService().fetchYearCounts();
    setState(() {
      landlordCount      = l;
      tenantCount        = t;
      apartmentCount     = a;
      boardingHouseCount = b;
      condoCount         = c;
      transientCount     = tr;
      yearCounts         = YearCountService().yearCounts;
      isLoading          = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final yearData = {
      for (var yc in yearCounts) yc.year.toString(): yc.count.toDouble()
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
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
                children: [
                  Expanded(
                    child: _buildPieChart(
                      "Total Users",
                      ["Landlords", "Tenants"],
                      [landlordCount?.toDouble() ?? 0, tenantCount?.toDouble() ?? 0],
                      [landlordsColor, tenantsColor],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDonutChart(
                      "Listed Properties",
                      ["Boarding House", "Condo", "Apartments", "Transient"],
                      [
                        boardingHouseCount?.toDouble() ?? 0,
                        condoCount?.toDouble() ?? 0,
                        apartmentCount?.toDouble() ?? 0,
                        transientCount?.toDouble() ?? 0,
                      ],
                      [boardingColor, dormColor, apartmentColor, transientColor],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _BarChartWithYearSelector(
                title: "Engagement Metrics",
                yearData: yearData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pie Chart builder
  Widget _buildPieChart(String title, List<String> labels, List<double> values, List<Color> colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 390;
        final radius = isSmall ? 80.0 : 120.0;
        return Column(
          children: [
            Container(
              height: isSmall ? 220 : 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
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
                              radius: radius,
                              title: '${labels[i]}\n${values[i] % 1 == 0 ? values[i].toInt() : values[i].toStringAsFixed(2)}',
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
                  if (!isSmall) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(labels.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text(labels[i], style: const TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
          ],
        );
      },
    );
  }

  // Donut Chart builder
  Widget _buildDonutChart(String title, List<String> labels, List<double> values, List<Color> colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 430;
        final total = values.fold<double>(0, (sum, v) => sum + v);
        final radius = isSmall ? 60.0 : 80.0;
        final centerRadius = isSmall ? 30.0 : 40.0;

        double fontSizeForWidth(double w) {
          if (w < 200) return 8;
          if (w < 300) return 10;
          return 12;
        }

        return Column(
          children: [
            Container(
              height: isSmall ? 220 : 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: centerRadius,
                              sections: List.generate(values.length, (i) {
                                final ratio = values[i] / total;
                                final fs    = fontSizeForWidth(constraints.maxWidth);
                                return PieChartSectionData(
                                  value: values[i],
                                  color: colors[i],
                                  radius: radius,
                                  title: '${values[i] % 1 == 0 ? values[i].toInt() : values[i].toStringAsFixed(2)}',

                                  titleStyle: TextStyle(fontSize: fs, fontWeight: FontWeight.w500, color: Colors.white),
                                  titlePositionPercentageOffset: ratio >= 0.1 ? 0.6 : 0.7,
                                );
                              }),
                            ),
                          ),
                          Text(total.toInt().toString(), style: TextStyle(fontSize: isSmall ? 14 : 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  if (!isSmall) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(labels.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text(labels[i], style: const TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
          ],
        );
      },
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────────
// Bar Chart with fixed height to avoid infinite constraints
// ───────────────────────────────────────────────────────────────────────────────
class _BarChartWithYearSelector extends StatefulWidget {
  final String title;
  final Map<String, double> yearData;

  const _BarChartWithYearSelector({
    required this.title,
    required this.yearData,
  });

  @override
  State<_BarChartWithYearSelector> createState() => _BarChartWithYearSelectorState();
}

class _BarChartWithYearSelectorState extends State<_BarChartWithYearSelector> {
  late String startYear, endYear;

  @override
  void initState() {
    super.initState();
    _updateYears();
  }

  @override
  void didUpdateWidget(covariant _BarChartWithYearSelector old) {
    super.didUpdateWidget(old);
    if (old.yearData != widget.yearData) _updateYears();
  }

  void _updateYears() {
    final years = widget.yearData.keys.toList()..sort();
    if (years.isNotEmpty) {
      startYear = years.first;
      endYear   = years.last;
    } else {
      startYear = endYear = '';
    }
  }

  // Update the getSelectedYears method in _BarChartWithYearSelectorState
  List<String> getSelectedYears() {
    if (startYear.isEmpty || endYear.isEmpty) return [];
    final start = int.parse(startYear);
    final end = int.parse(endYear);
    return List.generate(end - start + 1, (index) => (start + index).toString());
  }

  // Update the build method in _BarChartWithYearSelectorState
  @override
  Widget build(BuildContext context) {
    final allYears = widget.yearData.keys.toList()
      ..sort();
    final selectedYears = getSelectedYears();

    // Get data for all years in range, default to 0 if no data
    final selectedData = selectedYears.map((y) => widget.yearData[y] ?? 0.0).toList();

    // Compute Y-axis bounds
    final rawMax = selectedData.isEmpty ? 0 : selectedData.reduce(math.max);
    final maxY = (rawMax * 1.1).ceilToDouble();
    final yInt = (maxY / 5).ceilToDouble();

    final barColors = [
      const Color(0xFFA0BACB),
      const Color(0xFF5E636F),
      const Color(0xFF848FB1),
    ];

    // Create bar groups for all years in range
    final barGroups = List.generate(selectedData.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: selectedData[i],
            width: 30,
            color: barColors[i % barColors.length],
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: allYears.isEmpty
            ? const Center(child: Text("No year data available"))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Year selectors with DropdownButton2
                Column(
                  children: [
                    const Text("Start Year:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    DropdownButton2<String>(
                      value: startYear,
                      onChanged: (v) => setState(() => startYear = v!),
                      items: allYears
                          .where((y) => int.parse(y) <= int.parse(endYear))
                          .map((y) => DropdownMenuItem(
                        value: y,
                        child: Text(y),
                      ))
                          .toList(),
                      buttonStyleData: ButtonStyleData(
                        height: 40,
                        width: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        offset: const Offset(0, -5),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: MaterialStateProperty.all(6),
                          thumbVisibility: MaterialStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("End Year:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    DropdownButton2<String>(
                      value: endYear,
                      onChanged: (v) => setState(() => endYear = v!),
                      items: allYears
                          .where((y) => int.parse(y) >= int.parse(startYear))
                          .map((y) => DropdownMenuItem(
                        value: y,
                        child: Text(y),
                      ))
                          .toList(),
                      buttonStyleData: ButtonStyleData(
                        height: 40,
                        width: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        offset: const Offset(0, -5),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Bar chart
                Expanded(
                  child: SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final year = selectedYears[group.x.toInt()];
                              final value = rod.toY;
                              return BarTooltipItem(
                                '$year\n${value.toInt()}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        alignment: BarChartAlignment.spaceAround,
                        minY: 0,
                        maxY: maxY,
                        groupsSpace: 20,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: yInt,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= selectedYears.length) {
                                  return const SizedBox();
                                }
                                return Text(
                                  selectedYears[index],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: yInt,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 500.0),
              child: Text(
                'Users Growth report from $startYear to $endYear',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}