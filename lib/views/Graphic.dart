// lib/views/graph_page.dart
import 'package:flutter/material.dart';
import 'package:node_red_app/utils/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphPage extends StatefulWidget {
  final ValueNotifier<Map<String, List<ChartData>>> chartNotifier;

  const GraphPage({super.key, required this.chartNotifier, required Map chartData});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, List<ChartData>>>(
      valueListenable: widget.chartNotifier,
      builder: (context, chartData, _) {
        final hasAny = chartData.values.any((l) => l.isNotEmpty);

        return Scaffold(
          appBar: AppBar(title: const Text('Graphiques capteurs')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: !hasAny
                ? const Center(child: Text('Aucune donnée disponible'))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if ((chartData["temperature"] ?? []).isNotEmpty)
                          GraphCard(
                              title: 'Température (1h)',
                              chartData: chartData["temperature"]!,
                              color: Colors.red),
                        if ((chartData["humidity"] ?? []).isNotEmpty)
                          GraphCard(
                              title: 'Humidité (1h)',
                              chartData: chartData["humidity"]!,
                              color: Colors.blue),
                        if ((chartData["luminosity"] ?? []).isNotEmpty)
                          GraphCard(
                              title: 'Luminosité (1h)',
                              chartData: chartData["luminosity"]!,
                              color: Colors.orange),
                        if ((chartData["distance"] ?? []).isNotEmpty)
                          GraphCard(
                              title: 'Distance (1h)',
                              chartData: chartData["distance"]!,
                              color: Colors.purple),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class GraphCard extends StatelessWidget {
  final String title;
  final List<ChartData> chartData;
  final Color color;

  const GraphCard(
      {super.key, required this.title, required this.chartData, this.color = Colors.green});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
              height: 120,
              child: Center(child: Text('$title — pas de points'))),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis:
                    DateTimeAxis(intervalType: DateTimeIntervalType.minutes, interval: 5),
                primaryYAxis: NumericAxis(),
                series: <LineSeries<ChartData, DateTime>>[
                  LineSeries<ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.time,
                    yValueMapper: (d, _) => d.value,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: color,
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
