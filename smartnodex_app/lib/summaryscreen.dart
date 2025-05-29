import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, dynamic>? summaryData;
  bool isLoading = true;
  String errorMsg = "";

  Future<void> fetchSummary() async {
    final url = Uri.parse('https://tensorflowtitan.xyz/backend/summary.php');

    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body);

      if (json['success']) {
        setState(() {
          summaryData = json['data'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch summary");
      }
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSummary();
  }

  Widget statCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Summary Report")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : summaryData == null
                ? Center(child: Text("Error: $errorMsg"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Last update: ${summaryData!['last_update']}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            statCard("Avg Temp (°C)", summaryData!['avg_temp'],
                                Icons.thermostat, Colors.orange),
                            statCard(
                                "Avg Humidity (%)",
                                summaryData!['avg_hum'],
                                Icons.water_drop,
                                Colors.blue),
                            statCard("Max Temp", summaryData!['max_temp'],
                                Icons.trending_up, Colors.red),
                            statCard("Min Temp", summaryData!['min_temp'],
                                Icons.trending_down, Colors.green),
                            statCard("Max Humidity", summaryData!['max_hum'],
                                Icons.opacity, Colors.red),
                            statCard("Min Humidity", summaryData!['min_hum'],
                                Icons.opacity, Colors.green),
                            statCard(
                                "Total Readings",
                                summaryData!['total_readings'],
                                Icons.data_usage,
                                Colors.purple),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
