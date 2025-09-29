// lib/models/chart_data.dart
class ChartData {
  final DateTime time;
  final double value;
  ChartData(this.time, this.value);

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'value': value,
      };

  static ChartData fromJson(Map<String, dynamic> json) =>
      ChartData(DateTime.parse(json['time']), (json['value'] as num).toDouble());
}
