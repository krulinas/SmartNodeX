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
  List<FlSpot> humData = [];
  String statusMessage = "Loading...";
  String humidityStatus = "Loading...";

  Future<void> fetchSensorData() async {
    final response = await http.get(
      Uri.parse('https://tensorflowtitan.xyz/backend/fetch.php'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonData = decoded['data'];

      setState(() {
        tempData = [];
        humData = [];
        for (int i = 0; i < jsonData.length; i++) {
          final temp =
              double.tryParse(jsonData[i]['temperature'].toString()) ?? 0.0;
          final hum =
              double.tryParse(jsonData[i]['humidity'].toString()) ?? 0.0;
          tempData.add(FlSpot(i.toDouble(), temp));
          humData.add(FlSpot(i.toDouble(), hum));
        }

        final lastTemp = tempData.last.y;
        final lastHum = humData.last.y;
        statusMessage =
            lastTemp > 26.0 ? "⚠️ Alert: High Temp!" : "✅ Temperature Normal";
        humidityStatus =
            lastHum > 70 ? "⚠️ High Humidity!" : "✅ Humidity Normal";
      });
    } else {
      setState(() {
        statusMessage = "❌ Failed to load data.";
        humidityStatus = "❌ Failed to load data.";
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.thermostat, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(statusMessage,
                              style: const TextStyle(fontSize: 16))),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.water_drop, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(humidityStatus,
                              style: const TextStyle(fontSize: 16))),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Temperature Chart
            const Text("Temperature Trend (°C)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: tempData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 50,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5,
                              getTitlesWidget: (value, _) =>
                                  Text('${value.toInt()}°'),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
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
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Humidity Chart
            const Text("Humidity Trend (%)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: humData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                              getTitlesWidget: (value, _) =>
                                  Text('${value.toInt()}%'),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: humData.length > 30
                                ? humData.sublist(humData.length - 30)
                                : humData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.2)),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: fetchSensorData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Refresh"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
