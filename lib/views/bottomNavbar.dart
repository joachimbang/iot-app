// lib/views/bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:node_red_app/utils/chart_data.dart';
import 'package:node_red_app/views/Graphic.dart';
import 'home.dart';

class BottomNavbar extends StatefulWidget {
  final Map<String, List<ChartData>> initialChartData;

  const BottomNavbar({super.key, required this.initialChartData, required Map<String, List> chartData});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> with SingleTickerProviderStateMixin {
  late TabController controller;
  int _selectedIndex = 0;

  // Le ValueNotifier partagé entre Home et GraphPage
  late ValueNotifier<Map<String, List<ChartData>>> chartNotifier;

  @override
  void initState() {
    super.initState();
    chartNotifier = ValueNotifier({
      "temperature": List.from(widget.initialChartData["temperature"] ?? []),
      "humidity": List.from(widget.initialChartData["humidity"] ?? []),
      "luminosity": List.from(widget.initialChartData["luminosity"] ?? []),
      "distance": List.from(widget.initialChartData["distance"] ?? []),
    });

    controller = TabController(length: 2, vsync: this, initialIndex: _selectedIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    chartNotifier.dispose();
    super.dispose();
  }

  // Cette fonction sera appelée depuis Home pour mettre à jour le graphique
  void _onHomeChartDataUpdated(Map<String, List<ChartData>> newData) {
    if (!mounted) return;
    // Mise à jour sécurisée du ValueNotifier
    chartNotifier.value = {
      "temperature": List.from(newData["temperature"] ?? []),
      "humidity": List.from(newData["humidity"] ?? []),
      "luminosity": List.from(newData["luminosity"] ?? []),
      "distance": List.from(newData["distance"] ?? []),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Home reçoit la callback pour mettre à jour le notifier
                  Home(onChartDataUpdated: _onHomeChartDataUpdated),
                  // GraphPage reçoit le notifier pour les updates en live
                  GraphPage(chartNotifier: chartNotifier, chartData: {},),
                ],
              ),
            ),
            Row(
              children: [
                _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
                _buildNavItem(icon: Icons.show_chart, label: 'Graph', index: 1),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final selected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            controller.index = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: selected ? Colors.green.withOpacity(0.06) : Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? Colors.green : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
