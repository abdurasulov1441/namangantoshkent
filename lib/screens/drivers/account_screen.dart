import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namangantoshkent/style/app_colors.dart';
import 'package:namangantoshkent/style/app_style.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.taxi,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Akkaunt',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Chiqish',
            onPressed: () => signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orderStatistics')
            .where('completedBy', isEqualTo: user!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          int totalOrders = 0;
          int totalPeople = 0;
          int totalDeliveries = 0;

          for (var report in reports) {
            final data = report.data() as Map<String, dynamic>;
            final orderCount = data['orderCount'] as int;
            final peopleCount = data['peopleCount'] != null
                ? data['peopleCount'] as int
                : 0; // Если `peopleCount` null, используем 0
            final orderType = data['orderType'] ?? '';

            totalOrders += orderCount;

            if (orderType == 'taksi') {
              totalPeople += peopleCount;
            } else if (orderType == 'dostavka') {
              totalDeliveries += orderCount;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistika',
                          style: AppStyle.fontStyle.copyWith(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Jami buyurtmalar soni: $totalOrders',
                          style: AppStyle.fontStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Odamlar soni (taksi): $totalPeople',
                          style: AppStyle.fontStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Dostavka soni: $totalDeliveries',
                          style: AppStyle.fontStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
