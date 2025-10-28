import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TransactionsChart extends StatefulWidget {
  final List<dynamic> transactions;
  final String title;
  final Color accentColor;
  final bool isIncome;

  const TransactionsChart({
    super.key,
    required this.transactions,
    required this.title,
    required this.accentColor,
    this.isIncome = false,
  });

  @override
  State<TransactionsChart> createState() => _TransactionsChartState();
}

class _TransactionsChartState extends State<TransactionsChart> {
  String _selectedPeriod = "30 dias";

  List<dynamic> get _filteredTransactions {
    if (_selectedPeriod == "Tudo") return widget.transactions;

    final now = DateTime.now();
    final cutoff = now.subtract(Duration(
      days: _selectedPeriod == "7 dias" ? 7 : 30,
    ));
    return widget.transactions
        .where((t) => DateTime.parse(t['dateCreated']).isAfter(cutoff))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const darkFontColor = Color(0xFFC0B7B1);
    const darkSecondaryBg = Color(0xFF201D1E);

    final filtered = _filteredTransactions;
    if (filtered.isEmpty) {
      return const Text(
        'Sem dados suficientes para gerar o gráfico',
        style: TextStyle(color: darkFontColor),
        textAlign: TextAlign.center,
      );
    }

    // Agrupar por data
    final Map<String, double> grouped = {};
    for (var t in filtered) {
      final date = DateTime.parse(t['dateCreated']);
      final key =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      grouped[key] = (grouped[key] ?? 0) + (t['value'] ?? 0);
    }

    final data = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkSecondaryBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.accentColor.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + filtro
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: darkFontColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.accentColor.withValues(alpha: .4)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    dropdownColor: darkSecondaryBg,
                    style: const TextStyle(color: darkFontColor, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: "7 dias", child: Text("7 dias")),
                      DropdownMenuItem(value: "30 dias", child: Text("30 dias")),
                      DropdownMenuItem(value: "Tudo", child: Text("Tudo")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPeriod = value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Gráfico
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final label = data[i].key.split('-').sublist(1).join('/');
                        return Text(
                          label,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        "R\$${value.toInt()}",
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 9),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: widget.accentColor,
                    preventCurveOverShooting: true,
                    curveSmoothness: 0.35,
                    belowBarData: BarAreaData(
                      show: true,
                      color: widget.accentColor.withValues(alpha: 0.25),
                    ),
                    spots: [
                      for (int i = 0; i < data.length; i++)
                        FlSpot(i.toDouble(), data[i].value),
                    ],
                    dotData: FlDotData(show: false),
                    barWidth: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
