import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ===================== MAIN =====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESP32 MQTT App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Home(onChartDataUpdated: (newData) {  },), // démarrage direct sur Home
    );
  }
}

// ===================== HOME =====================
class Home extends StatefulWidget {
  const Home({super.key, required Null Function(dynamic newData) onChartDataUpdated});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ----------------- MQTT -----------------
  final client = MqttServerClient('broker.hivemq.com', '');
  bool isConnected = false;

  // ----------------- Capteurs & actionneurs -----------------
  bool ledState = false;
  int servoDegree = 0;
  double temperature = 0;
  double humidity = 0;
  int ldrValue = 0;
  double distance = 0;

  // ----------------- Données graphiques -----------------
  Map<String, List<ChartData>> chartData = {
    "temperature": [],
    "humidity": [],
    "luminosity": [],
    "distance": [],
  };

  Timer? chartTimer;

  @override
  void initState() {
    super.initState();
    loadChartData().then((_) {
      setupMqtt();

      chartTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        addSensorData();
      });
    });
  }

  // ----------------- SHARED PREFERENCES -----------------
  Future<void> saveChartData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = chartData.map((key, list) => MapEntry(
        key,
        list
            .map((e) => {'time': e.time.toIso8601String(), 'value': e.value})
            .toList()));
    await prefs.setString('chartData', jsonEncode(jsonData));
  }

  Future<void> loadChartData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('chartData');
    if (jsonString != null) {
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      chartData = jsonData.map((key, list) => MapEntry(
          key,
          (list as List<dynamic>)
              .map((e) => ChartData(DateTime.parse(e['time']), e['value']))
              .toList()));
    }
  }

  void addSensorData() {
    final now = DateTime.now();
    setState(() {
      chartData["temperature"]!.add(ChartData(now, temperature));
      chartData["humidity"]!.add(ChartData(now, humidity));
      chartData["luminosity"]!.add(ChartData(now, ldrValue.toDouble()));
      chartData["distance"]!.add(ChartData(now, distance));

      for (var key in chartData.keys) {
        chartData[key] = chartData[key]!
            .where((d) => now.difference(d.time).inMinutes <= 60)
            .toList();
      }
      saveChartData();
    });
  }

  // ----------------- CONFIGURATION MQTT -----------------
  Future<void> setupMqtt() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.setProtocolV311();
    client.autoReconnect = true;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
            'FlutterClient-${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('MQTT Exception: $e');
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final payload = String.fromCharCodes(recMess.payload.message);
      final topic = c[0].topic;

      debugPrint('Message reçu: $payload sur $topic');

      setState(() {
        switch (topic) {
          case 'tp/dht11':
            final parts = payload.split(',');
            if (parts.length >= 2) {
              temperature = double.tryParse(parts[0]) ?? 0;
              humidity = double.tryParse(parts[1]) ?? 0;
              addSensorData();
            }
            break;
          case 'tp/ldr':
            ldrValue = int.tryParse(payload) ?? 0;
            addSensorData();
            break;
          case 'tp/distance':
            distance = double.tryParse(payload) ?? 0;
            addSensorData();
            break;
        }
      });
    });

    client.subscribe('tp/dht11', MqttQos.atMostOnce);
    client.subscribe('tp/ldr', MqttQos.atMostOnce);
    client.subscribe('tp/distance', MqttQos.atMostOnce);
  }

  void onConnected() {
    setState(() => isConnected = true);
    debugPrint('✅ MQTT connecté');
  }

  void onDisconnected() {
    setState(() => isConnected = false);
    debugPrint('❌ MQTT déconnecté');
  }

  void onSubscribed(String topic) {
    debugPrint('➡️ Abonné à: $topic');
  }

  // ----------------- ACTIONS -----------------
  void toggleLed() {
    setState(() => ledState = !ledState);
    final msg = ledState ? 'ON' : 'OFF';
    final buffer = Uint8Buffer()..addAll(msg.codeUnits);
    client.publishMessage('tp/led', MqttQos.atMostOnce, buffer);
  }

  void moveServo(int degree) {
    setState(() => servoDegree = degree);
    final buffer = Uint8Buffer()..addAll(degree.toString().codeUnits);
    client.publishMessage('tp/servo', MqttQos.atMostOnce, buffer);
  }

  // ----------------- BUILD UI -----------------
  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width / 4) - 16;

    return Scaffold(
      appBar: AppBar(title: const Text('ESP32 MQTT')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Connexion MQTT: ${isConnected ? "✅ Connecté" : "❌ Déconnecté"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SensorCard(
                      icon: Icons.thermostat,
                      title: 'Température',
                      value: '${temperature.toStringAsFixed(2)} °C',
                      width: cardWidth),
                  SensorCard(
                      icon: Icons.water_damage,
                      title: 'Humidité',
                      value: '${humidity.toStringAsFixed(2)} %',
                      width: cardWidth),
                  SensorCard(
                      icon: Icons.light_mode,
                      title: 'Luminosité',
                      value: '$ldrValue',
                      width: cardWidth),
                  SensorCard(
                      icon: Icons.straighten,
                      title: 'Distance',
                      value: '${distance.toStringAsFixed(2)} cm',
                      width: cardWidth),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: toggleLed,
                child: Text(ledState ? 'Éteindre LED' : 'Allumer LED'),
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
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 15,
                      cornerStyle: gauges.CornerStyle.bothFlat,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.RangePointer(
                        value: servoDegree.toDouble(),
                        width: 15,
                        color: Colors.green,
                        enableAnimation: true,
                      ),
                      gauges.MarkerPointer(
                        value: servoDegree.toDouble(),
                        markerType: gauges.MarkerType.circle,
                        color: Colors.white,
                        borderWidth: 3,
                        borderColor: Colors.green,
                        markerHeight: 25,
                        markerWidth: 25,
                        enableDragging: true,
                        onValueChanged: (value) {
                          setState(() {
                            servoDegree = value.toInt();
                            moveServo(servoDegree);
                          });
                        },
                      ),
                    ],
                    annotations: <gauges.GaugeAnnotation>[
                      gauges.GaugeAnnotation(
                        widget: Text(
                          '$servoDegree°',
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
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

  @override
  void dispose() {
    client.disconnect();
    chartTimer?.cancel();
    super.dispose();
  }
}

// ===================== WIDGETS =====================
class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double width;

  const SensorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== DATA MODEL =====================
class ChartData {
  final DateTime time;
  final double value;
  ChartData(this.time, this.value);
}
