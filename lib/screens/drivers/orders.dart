import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namangantoshkent/screens/drivers/account_screen.dart';
import 'package:namangantoshkent/style/app_colors.dart';
import 'package:namangantoshkent/style/app_style.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _acceptOrder(String orderId, String orderType) async {
    if (_user == null) {
      _showSnackBar('User not authenticated');
      return;
    }

    final orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);
    final driverRef =
        FirebaseFirestore.instance.collection('drivers').doc(_user!.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);

      if (orderSnapshot.exists && orderSnapshot['status'] == 'pending') {
        // Update the order status and assign it to the current driver
        transaction.update(orderRef, {
          'status': 'accepted',
          'driverId': _user!.uid,
          'driverEmail': _user!.email,
        });

        transaction.set(driverRef.collection('acceptedOrders').doc(orderId),
            orderSnapshot.data()!);
      }
    });

    if (mounted) {
      _showSnackBar('Buyurtma qabul qilindi');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Barcha buyurtmalar',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.taxi,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
            icon: Icon(
              Icons.person,
              color: (_user == null) ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;
              final orderType = orderData['orderType'];

              // Добавляем 5 часов к orderTime
              final orderTime = orderData['orderTime'].toDate();
              final orderTimeInUtcPlus5 = orderTime.add(const Duration(hours: 5));

              return Card(
                color: Colors.white,
                elevation: 5,
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.taxi,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${orderData['fromLocation']} dan ${orderData['toLocation']} gacha',
                              style: AppStyle.fontStyle.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            orderType == 'taksi'
                                ? Icons.person
                                : Icons.local_shipping,
                            color: AppColors.taxi,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            orderType == 'taksi'
                                ? 'Odamlar: ${orderData['peopleCount']}'
                                : 'Dostavka: ${orderData['itemDescription']}',
                            style: AppStyle.fontStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.taxi,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Vaqt: ${DateFormat('yyyy-MM-dd – HH:mm').format(orderTimeInUtcPlus5)}',
                            style: AppStyle.fontStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            backgroundColor: AppColors.taxi,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () => _acceptOrder(order.id, orderType),
                          child: Text(
                            'Qabul qilish',
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
