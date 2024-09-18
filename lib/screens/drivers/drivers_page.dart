import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Orders(),
          AcceptedOrdersPage(),
          StatisticsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Buyurtmalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Qabul qilingan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart),
            label: 'Statistika',
          ),
        ],
        selectedItemColor: AppColors.taxi,
      ),
      // floatingActionButton: FloatingActionButton(
      //   elevation: 5,
      //   backgroundColor: Colors.white,
      //   shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(30))),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => ChatPage()),
      //     );
      //   },
      //   child: Icon(
      //     Icons.chat,
      //     color: AppColors.taxi,
      //   ),
      // ),
    );
  }
}
