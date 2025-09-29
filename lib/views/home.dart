import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:node_red_app/utils/chart_data.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:typed_data/typed_buffers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key, required void Function(Map<String, List<ChartData>> newData) onChartDataUpdated});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final client = MqttServerClient('broker.hivemq.com', '');
  bool isConnected = false;

  bool ledState = false;
  int servoDegree = 0;
  double temperature = 0;
  double humidity = 0;
  int ldrValue = 0;
  double distance = 0;

  Map<String, ListQueue<ChartData>> chartData = {
    "temperature": ListQueue<ChartData>(),
    "humidity": ListQueue<ChartData>(),
    "luminosity": ListQueue<ChartData>(),
    "distance": ListQueue<ChartData>(),
  };
  static const int maxPoints = 60;

  final ValueNotifier<Map<String, List<ChartData>>> chartNotifier = ValueNotifier({});

  Timer? chartTimer;
  StreamSubscription? mqttSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadChartData().then((_) {
      if (!mounted) return;
      chartNotifier.value = chartData.map((k, v) => MapEntry(k, v.toList()));
      setupMqtt();
      chartTimer = Timer.periodic(const Duration(seconds: 2), (_) => addSensorData());
    });
  }

  @override
  void dispose() {
    chartTimer?.cancel();
    mqttSub?.cancel();
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.disconnect();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.paused) {
      chartTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      chartTimer ??= Timer.periodic(const Duration(seconds: 2), (_) => addSensorData());
    }
  }

  Future<void> saveChartData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = chartData.map((key, list) => MapEntry(key, list.map((e) => e.toJson()).toList()));
    await prefs.setString('chartData', jsonEncode(jsonData));
  }

  Future<void> loadChartData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('chartData');
    if (jsonString == null) return;
    try {
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      jsonData.forEach((key, list) {
        final q = ListQueue<ChartData>();
        for (final e in (list as List<dynamic>)) {
          q.add(ChartData.fromJson(Map<String, dynamic>.from(e)));
        }
        chartData[key] = q;
      });
    } catch (e) {
      debugPrint('loadChartData error: $e');
    }
  }

  void addSensorData() {
    if (!mounted) return;
    final now = DateTime.now();
    _addPointSafe("temperature", temperature, now);
    _addPointSafe("humidity", humidity, now);
    _addPointSafe("luminosity", ldrValue.toDouble(), now);
    _addPointSafe("distance", distance, now);

    chartNotifier.value = chartData.map((k, v) => MapEntry(k, v.toList()));
    saveChartData();
  }

  void _addPointSafe(String key, double value, DateTime now) {
    if (value.isNaN) return;
    final q = chartData[key]!;
    if (q.length >= maxPoints) q.removeFirst();
    q.add(ChartData(now, value));
  }

  Future<void> setupMqtt() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.setProtocolV311();
    client.autoReconnect = true;

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('FlutterClient-${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    try {
      await client.connect();
    } catch (e) {
      debugPrint('MQTT Exception: $e');
      client.disconnect();
      return;
    }

    mqttSub = client.updates?.listen((c) {
      if (!mounted) return;
      if (c == null || c.isEmpty) return;
      final recMess = c[0].payload as MqttPublishMessage;
      final payload = String.fromCharCodes(recMess.payload.message);
      final topic = c[0].topic;

      try {
        switch (topic) {
          case 'tp/dht11':
            final parts = payload.split(',');
            if (parts.length >= 2) {
              final tString = parts[0].replaceAll('°C', '').trim();
              final hString = parts[1].replaceAll('%', '').trim();
              final t = double.tryParse(tString);
              final h = double.tryParse(hString);
              if (t != null) temperature = t;
              if (h != null) humidity = h;
            }
            break;
          case 'tp/ldr':
            final l = int.tryParse(payload);
            if (l != null) ldrValue = l;
            break;
          case 'tp/distance':
            final d = double.tryParse(payload);
            if (d != null) distance = d;
            break;
        }
        setState(() {}); // 🔹 update UI seulement si mounted
      } catch (e) {
        debugPrint('MQTT processing error: $e');
      }
    });

    client.subscribe('tp/dht11', MqttQos.atMostOnce);
    client.subscribe('tp/ldr', MqttQos.atMostOnce);
    client.subscribe('tp/distance', MqttQos.atMostOnce);
  }

  void onConnected() {
    if (!mounted) return;
    setState(() => isConnected = true);
    debugPrint('✅ MQTT connecté');
  }

  void onDisconnected() {
    if (!mounted) return;
    setState(() => isConnected = false);
    debugPrint('❌ MQTT déconnecté');
  }

  void onSubscribed(String topic) => debugPrint('➡️ Abonné à: $topic');

  void toggleLed() {
    final newState = !ledState;
    if (!mounted) return;
    setState(() => ledState = newState);
    final buffer = Uint8Buffer()..addAll((newState ? 'ON' : 'OFF').codeUnits);
    try {
      client.publishMessage('tp/led', MqttQos.atMostOnce, buffer);
    } catch (e) {
      debugPrint('publish led error: $e');
    }
  }

  void moveServo(int degree) {
    if (!mounted) return;
    setState(() => servoDegree = degree);
    final buffer = Uint8Buffer()..addAll(degree.toString().codeUnits);
    try {
      client.publishMessage('tp/servo', MqttQos.atMostOnce, buffer);
    } catch (e) {
      debugPrint('publish servo error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width / 2) - 24;
    final hasData = temperature != 0 || humidity != 0 || ldrValue != 0 || distance != 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 MQTT'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.wifi, color: isConnected ? Colors.green : Colors.red),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: !hasData
            ? const Center(
                child: Text(
                  "⚠️ Aucune donnée reçue.\nVeuillez vérifier vos branchements.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LedCard(isOn: ledState, onToggle: toggleLed, width: cardWidth),
                        _ConnectionCard(connected: isConnected, width: cardWidth),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            _SensorCard(icon: Icons.thermostat, title: 'Température', value: '${temperature.toStringAsFixed(1)} °C', width: cardWidth),
                            const SizedBox(height: 8),
                            _SensorCard(icon: Icons.water_drop, title: 'Humidité', value: '${humidity.toStringAsFixed(1)} %', width: cardWidth),
                          ],
                        ),
                        Column(
                          children: [
                            _SensorCard(icon: Icons.light_mode, title: 'Luminosité', value: '$ldrValue', width: cardWidth),
                            const SizedBox(height: 8),
                            _SensorCard(icon: Icons.straighten, title: 'Distance', value: '${distance.toStringAsFixed(1)} cm', width: cardWidth),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    gauges.SfRadialGauge(
                      axes: <gauges.RadialAxis>[
                        gauges.RadialAxis(
                          minimum: 0,
                          maximum: 180,
                          startAngle: 180,
                          endAngle: 0,
                          showLabels: true,
                          showTicks: true,
                          axisLineStyle: const gauges.AxisLineStyle(thickness: 15),
                          pointers: <gauges.GaugePointer>[
                            gauges.RangePointer(value: servoDegree.toDouble(), width: 15, enableAnimation: true),
                            gauges.MarkerPointer(
                              value: servoDegree.toDouble(),
                              markerType: gauges.MarkerType.circle,
                              markerHeight: 25,
                              markerWidth: 25,
                              enableDragging: true,
                              onValueChanged: (val) => moveServo(val.toInt()),
                            ),
                          ],
                          annotations: <gauges.GaugeAnnotation>[
                            gauges.GaugeAnnotation(
                              widget: Text('$servoDegree°', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              angle: 90,
                              positionFactor: 0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// --- Cartes ---
class _SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double width;

  const _SensorCard({required this.icon, required this.title, required this.value, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}

class _LedCard extends StatelessWidget {
  final bool isOn;
  final VoidCallback onToggle;
  final double width;

  const _LedCard({required this.isOn, required this.onToggle, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: isOn ? Colors.yellow : Colors.grey, size: 48),
              const SizedBox(width: 12),
              Expanded(child: Text(isOn ? 'On' : 'Off', style: const TextStyle(fontSize: 16))),
              IconButton(onPressed: onToggle, icon: const Icon(Icons.power_settings_new)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final bool connected;
  final double width;

  const _ConnectionCard({required this.connected, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(Icons.wifi, color: connected ? Colors.green : Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(connected ? 'Connecté' : 'Déconnecté'),
            ],
          ),
        ),
      ),
    );
  }
}
