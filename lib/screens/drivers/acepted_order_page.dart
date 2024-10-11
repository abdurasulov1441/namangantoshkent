import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namangantoshkent/screens/drivers/account_screen.dart';
import 'package:namangantoshkent/style/app_colors.dart';
import 'package:namangantoshkent/style/app_style.dart';
import 'package:permission_handler/permission_handler.dart';

class AcceptedOrdersPage extends StatefulWidget {
  const AcceptedOrdersPage({super.key});

  @override
  _AcceptedOrdersPageState createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  bool _isAccountValid = false;
  bool _isLoading = true;
  Map<String, bool> _loadingReject = {}; // To track loading state for Qaytarish
  Map<String, bool> _loadingFinalize =
      {}; // To track loading state for Yakunlash

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _checkAccountStatus();
  }

  Future<void> _checkAccountStatus() async {
    if (_user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      final disabled = data['disabled'] as bool? ?? false;
      final expiryDate = (data['expiry_date'] as Timestamp?)?.toDate();

      setState(() {
        _isAccountValid = !disabled &&
            expiryDate != null &&
            expiryDate.isAfter(DateTime.now());
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Request CALL_PHONE permission
    final status = await Permission.phone.request();

    if (status.isGranted) {
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
    } else {
      _showSnackBar('Qo‘ng‘iroq qilish uchun ruxsat talab qilinadi');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _rejectOrder(String orderId) async {
    setState(() {
      _loadingReject[orderId] = true;
    });

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
    setState(() {
      _loadingReject[orderId] = false;
    });
  }

  Future<void> _finalizeOrder(
      String orderId, Map<String, dynamic> orderData) async {
    setState(() {
      _loadingFinalize[orderId] = true;
    });

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

      transaction.set(statsRef.doc(), {
        'completedBy': driverEmail,
        'orderCount': 1,
        'peopleCount': peopleCount,
        'orderType': orderType,
        'itemDescription': itemDescription,
        'completedAt': Timestamp.now(),
      });

      transaction.delete(driverRef.collection('acceptedOrders').doc(orderId));
      transaction.delete(orderRef);
    });

    _showSnackBar('Buyurtma yakunlandi va hisobotga qo\'shildi');
    setState(() {
      _loadingFinalize[orderId] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAccountValid) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.taxi,
          title: Text(
            'Qabul qilingan arizalar',
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 60, color: AppColors.taxi),
                  const SizedBox(height: 15),
                  Text(
                    'Xizmatdan foydalanish uchun oylik to\'lovni amalga oshiring',
                    textAlign: TextAlign.center,
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.taxi,
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
            icon: Icon(Icons.person, color: Colors.white),
          ),
        ],
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
              final orderTime = orderData['orderTime'].toDate();
              final orderTimeInUtcPlus5 = orderTime.add(Duration(hours: 5));

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
                      Row(
                        children: [
                          Text('Telefon: ${orderData['phoneNumber']}'),
                          IconButton(
                            icon: Icon(Icons.phone, color: Colors.green),
                            onPressed: () =>
                                _makePhoneCall(orderData['phoneNumber']),
                          ),
                        ],
                      ),
                      Text(
                        'Ketish vaqti: ${DateFormat('yyyy-MM-dd – HH:mm').format(orderTimeInUtcPlus5)}',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _loadingReject[order.id] == true
                                ? null
                                : () => _rejectOrder(order.id),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              backgroundColor: AppColors.taxi,
                            ),
                            child: _loadingReject[order.id] == true
                                ? const SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
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
                                _makePhoneCall(orderData['phoneNumber']),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              backgroundColor: AppColors.taxi,
                            ),
                            child: Text(
                              'Bog\'lanish',
                              style: AppStyle.fontStyle.copyWith(
                                  fontSize: 12,
                                  color: AppColors.headerColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _loadingFinalize[order.id] == true
                                ? null
                                : () => _finalizeOrder(order.id, orderData),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              backgroundColor: Colors.red,
                            ),
                            child: _loadingFinalize[order.id] == true
                                ? const SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
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
