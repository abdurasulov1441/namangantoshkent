import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namangantoshkent/screens/drivers/account_screen.dart';
import 'package:namangantoshkent/style/app_colors.dart';
import 'package:namangantoshkent/style/app_style.dart';

class AcceptedOrdersPage extends StatefulWidget {
  const AcceptedOrdersPage({super.key});

  @override
  _AcceptedOrdersPageState createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _rejectOrder(String orderId) async {
    final orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);
    final driverRef =
        FirebaseFirestore.instance.collection('drivers').doc(_user!.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      final driverSnapshot = await transaction
          .get(driverRef.collection('acceptedOrders').doc(orderId));

      if (orderSnapshot.exists && driverSnapshot.exists) {
        transaction.update(orderRef, {
          'status': 'pending',
          'driverId': null,
          'driverPhoneNumber': null,
        });

        transaction.delete(driverSnapshot.reference);
      }
    });

    _showSnackBar('Buyurtma bekor qilindi');
  }

  Future<void> _finalizeOrder(
      String orderId, Map<String, dynamic> orderData) async {
    final statsRef = FirebaseFirestore.instance.collection('orderStatistics');
    final orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);
    final driverRef =
        FirebaseFirestore.instance.collection('drivers').doc(_user!.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final driverEmail = _user!.email;
      final peopleCount = orderData['peopleCount'] ?? 0;
      final orderType = orderData['orderType'] ?? 'unknown';
      final itemDescription = orderData['itemDescription'] ?? '';

      // Store the statistics in the `orderStatistics` collection
      transaction.set(statsRef.doc(), {
        'completedBy': driverEmail,
        'orderCount': 1,
        'peopleCount': peopleCount,
        'orderType': orderType,
        'itemDescription': itemDescription,
        'completedAt': Timestamp.now(),
      });

      // Remove the order from the driver's accepted orders
      transaction.delete(driverRef.collection('acceptedOrders').doc(orderId));
      // Remove the order from the main `orders` collection
      transaction.delete(orderRef);
    });

    _showSnackBar('Buyurtma yakunlandi va hisobotga qo\'shildi');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Qabul qilingan arizalar',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
              color: (user == null) ? Colors.white : Colors.white,
            ),
          ),
        ],
        backgroundColor: AppColors.taxi,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('drivers')
            .doc(_user!.uid)
            .collection('acceptedOrders')
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
                      Text(
                        '${orderData['fromLocation']} dan ${orderData['toLocation']} gacha',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      orderType == 'taksi'
                          ? Text('Odamlar soni: ${orderData['peopleCount']}')
                          : Text('Dostavka: ${orderData['itemDescription']}'),
                      Text('Telefon: ${orderData['phoneNumber']}'),
                      Text(
                          'Ketish vaqti: ${DateFormat('yyyy-MM-dd – HH:mm').format(orderTimeInUtcPlus5)}'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _rejectOrder(order.id),
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              'Qaytarish',
                              style: AppStyle.fontStyle.copyWith(
                                  fontSize: 12,
                                  color: AppColors.headerColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () =>
                                _finalizeOrder(order.id, orderData),
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              backgroundColor: Colors.green,
                            ),
                            child: Text(
                              'Yakunlash',
                              style: AppStyle.fontStyle.copyWith(
                                  fontSize: 12,
                                  color: AppColors.headerColor,
                                  fontWeight: FontWeight.bold),
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
        },
      ),
    );
  }
}
