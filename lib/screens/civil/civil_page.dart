import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namangantoshkent/screens/civil/delivery_page.dart';
import 'package:namangantoshkent/screens/civil/taksi_page.dart';
import 'package:namangantoshkent/screens/sign/login_screen.dart';
import 'package:namangantoshkent/style/app_colors.dart';
import 'package:namangantoshkent/style/app_style.dart';

class MainCivilPage extends StatefulWidget {
  const MainCivilPage({super.key});

  @override
  _MainCivilPageState createState() => _MainCivilPageState();
}

class _MainCivilPageState extends State<MainCivilPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TaxiPage(),
    const DeliveryPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Asosiy sahifa',
          style: AppStyle.fontStyle.copyWith(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.taxi,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: 'Taksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Pochta yuborish',
          ),
        ],
        selectedItemColor: AppColors.taxi,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
      ),
    );
  }
}
