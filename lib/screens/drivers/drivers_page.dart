import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:namangantoshkent/screens/drivers/acepted_order_page.dart';
import 'package:namangantoshkent/screens/drivers/orders.dart';
import 'package:namangantoshkent/screens/drivers/statistics_page.dart';
import 'package:namangantoshkent/style/app_colors.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildNavItem({
    required String iconPath,
    required String label,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Minimize the vertical space used
      mainAxisAlignment: MainAxisAlignment.center, // Center the items
      children: [
        if (isSelected)
          Container(
            height: 3, // Thinner line to save space
            width: double.infinity,
            color: AppColors.taxi, // Line color for selected item
          ),
        const SizedBox(height: 4), // Reduce space between line and icon
        SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          color: isSelected ? AppColors.taxi : Colors.grey,
        ),
        const SizedBox(height: 2), // Reduce space between icon and text
        Text(
          label,
          style: TextStyle(
            fontSize: 12, // Keep font size compact
            color: isSelected ? AppColors.taxi : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Orders(),
          AcceptedOrdersPage(),
          StatisticsPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 0), // No extra bottom padding
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Prevent resizing on tap
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _buildNavItem(
                iconPath: 'assets/icons/orders.svg',
                label: 'Buyurtmalar',
                isSelected: _currentIndex == 0,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItem(
                iconPath: 'assets/icons/accepted.svg',
                label: 'Qabul qilingan',
                isSelected: _currentIndex == 1,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItem(
                iconPath: 'assets/icons/statistics.svg',
                label: 'Statistika',
                isSelected: _currentIndex == 2,
              ),
              label: '',
            ),
          ],
          selectedItemColor: AppColors.taxi,
          backgroundColor: Colors.white,
          elevation: 8, // Keeps slight elevation for effect
        ),
      ),
    );
  }
}
