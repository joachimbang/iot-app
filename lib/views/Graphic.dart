import 'package:flutter/material.dart';
import 'package:node_red_app/views/home.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'main.dart'; // Pour ChartData si besoin

class GraphPage extends StatelessWidget {
  final Map<String, List<ChartData>> chartData;

  const GraphPage({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graphiques capteurs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GraphCard(
                  title: 'Température (1h)',
                  chartData: chartData["temperature"]!,
                  color: Colors.red),
              GraphCard(
                  title: 'Humidité (1h)',
                  chartData: chartData["humidity"]!,
                  color: Colors.blue),
              GraphCard(
                  title: 'Luminosité (1h)',
                  chartData: chartData["luminosity"]!,
                  color: Colors.orange),
              GraphCard(
                  title: 'Distance (1h)',
                  chartData: chartData["distance"]!,
                  color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphCard extends StatelessWidget {
  final String title;
  final List<ChartData> chartData;
  final Color color;

  const GraphCard({
    super.key,
    required this.title,
    required this.chartData,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.minutes,
                  interval: 2,
                ),
                primaryYAxis: NumericAxis(),
                series: <LineSeries<ChartData, DateTime>>[
                  LineSeries<ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.time,
                    yValueMapper: (ChartData data, _) => data.value,
                    color: color,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
