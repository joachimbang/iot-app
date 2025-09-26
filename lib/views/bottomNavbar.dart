import 'package:flutter/material.dart';
import 'package:node_red_app/services/style.dart';
import 'package:node_red_app/utils/extension.dart';
import 'package:node_red_app/views/Graphic.dart';
import 'package:node_red_app/views/home.dart';
// import 'main.dart'; // Pour ChartData si nécessaire

class BottomNavbar extends StatefulWidget {
  final Map<String, List<ChartData>> chartData;

  const BottomNavbar({Key? key, required this.chartData}) : super(key: key);
  static String routename = "/admin_home";

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController controller;

  @override
  void initState() {
    controller = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller,
                children: [
                  Home(
                    onChartDataUpdated: (newData) {
                      setState(() {
                        widget.chartData.addAll(newData);
                      });
                    },
                  ),
                  GraphPage(chartData: widget.chartData),
                ],
              ),
            ),
            Row(
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: "Home",
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.graphic_eq,
                  label: "Graph",
                  index: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            controller.index = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppStyle.PRIMERYCOLOR : Colors.grey,
              ),
              AppStyle.SPACING_XS.heightBox,
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppStyle.PRIMERYCOLOR : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
