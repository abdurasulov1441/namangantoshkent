import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
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

  Future<void> _makePhoneCall() async {
    const phoneNumber = '1250';
    final intent = AndroidIntent(
      action: 'android.intent.action.CALL',
      data: 'tel:$phoneNumber',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );

    try {
      await intent.launch();
    } catch (e) {
      _showSnackBar(
          'Qo\'ng\'iroq amalga oshirilmadi. Iltimos, telefon sozlamalarini tekshiring.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPhoneDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_in_talk,
                  size: 60,
                  color: AppColors.taxi,
                ),
                const SizedBox(height: 15),
                Text(
                  'Telefon orqali buyurtma qilish',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Buyurtmani telefon orqali ham qilishingiz mumkin. Qong\'iroq qilmoqchimisz?',
                  textAlign: TextAlign.center,
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text(
                        'Yo\'q',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                            context); // Close the dialog before calling
                        _makePhoneCall();
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        'Ha',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.taxi,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
        leading: IconButton(
          icon: const Icon(
            Icons.phone,
            color: Colors.white,
          ),
          onPressed: _showPhoneDialog,
        ),
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
