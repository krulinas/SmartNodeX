import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<FlSpot> tempData = [];
  String statusMessage = "Loading...";

  Future<void> fetchSensorData() async {
    final response = await http.get(
      Uri.parse('https://tensorflowtitan.xyz/backend/fetch.php'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonData = decoded['data'];
      setState(() {
        tempData = [];
        for (int i = 0; i < jsonData.length; i++) {
          final temp =
              double.tryParse(jsonData[i]['temperature'].toString()) ?? 0.0;
          tempData.add(FlSpot(i.toDouble(), temp));
        }
        final lastTemp = tempData.last.y;
        statusMessage =
            lastTemp > 26.0 ? "⚠️ Alert: High Temp!" : "✅ Temperature Normal";
      });
    } else {
      setState(() {
        statusMessage = "❌ Failed to load data.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartNodeX Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(statusMessage,
                            style: const TextStyle(fontSize: 16))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Temperature Trend",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: tempData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 40,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 5,
                              getTitlesWidget: (value, _) =>
                                  Text('${value.toInt()}°'),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                              getTitlesWidget: (value, _) =>
                                  Text(value.toInt().toString()),
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          verticalInterval: 10,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (_) => FlLine(
                              color: Colors.grey.shade300, strokeWidth: 1),
                          getDrawingVerticalLine: (_) => FlLine(
                              color: Colors.grey.shade300, strokeWidth: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: tempData.length > 30
                                ? tempData.sublist(tempData.length - 30)
                                : tempData,
                            isCurved: true,
                            color: Colors.deepOrange,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.orange.withOpacity(0.2)),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        borderData: FlBorderData(show: true),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: fetchSensorData,
                child: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
