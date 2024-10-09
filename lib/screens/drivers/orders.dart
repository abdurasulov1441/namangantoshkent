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
  Map<String, bool> _loadingOrders = {};
  List<DocumentSnapshot> _orders = [];
  String _selectedFilter = 'Barchasi'; // Updated filter state with 'Barchasi'

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _handleOrderAcceptance(String orderId, String orderType) async {
    if (_user == null) {
      _showSnackBar('User not authenticated');
      return;
    }

    setState(() {
      _loadingOrders[orderId] = true;
    });

    final orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);
    final driverRef =
        FirebaseFirestore.instance.collection('drivers').doc(_user!.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final orderSnapshot = await transaction.get(orderRef);

        if (orderSnapshot.exists && orderSnapshot['status'] == 'pending') {
          transaction.update(orderRef, {
            'status': 'accepted',
            'driverId': _user!.uid,
            'driverEmail': _user!.email,
          });

          transaction.set(driverRef.collection('acceptedOrders').doc(orderId),
              orderSnapshot.data()!);
        }
      });

      _showSnackBar('Buyurtma qabul qilindi');
      setState(() {
        _orders.removeWhere((order) => order.id == orderId); // Remove the card
      });
    } catch (e) {
      _showSnackBar('Error accepting order: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingOrders[orderId] = false;
        });
      }
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
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        backgroundColor: AppColors.taxi,
        title: Text(
          'Barcha buyurtmalar',
          style: AppStyle.fontStyle.copyWith(
              color: AppColors.backgroundColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter Row containing the text and dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Buyurtmani tanlang', // Text for the filter label
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Dropdown Button for filtering with outline style
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5.0, // Reduced vertical padding
                          horizontal: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              BorderSide(color: AppColors.taxi, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              BorderSide(color: AppColors.taxi, width: 2),
                        ),
                      ),
                      value: _selectedFilter,
                      isExpanded: true,
                      items: <String>['Barchasi', 'Odamlar', 'Dostavka']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFilter = newValue!;
                        });
                      },
                      dropdownColor: Colors.white,
                      style: AppStyle.fontStyle.copyWith(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                _orders = snapshot.data!.docs;

                // Apply filtering based on the selected filter
                List<DocumentSnapshot> filteredOrders = _orders.where((order) {
                  final orderData = order.data() as Map<String, dynamic>;
                  if (_selectedFilter == 'Barchasi') {
                    return true;
                  } else if (_selectedFilter == 'Odamlar' &&
                      orderData['orderType'] == 'taksi') {
                    return true;
                  } else if (_selectedFilter == 'Dostavka' &&
                      orderData['orderType'] == 'dostavka') {
                    return true;
                  }
                  return false;
                }).toList();

                return ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final orderData = order.data() as Map<String, dynamic>;
                    final orderType = orderData['orderType'];

                    final orderTime = orderData['orderTime'].toDate();
                    final orderTimeInUtcPlus5 =
                        orderTime.add(Duration(hours: 5));

                    final isLoading = _loadingOrders[order.id] ?? false;

                    return Card(
                      margin: const EdgeInsets.all(10.0),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: AppColors.taxi, size: 20),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    '${orderData['fromLocation']} dan ${orderData['toLocation']} gacha',
                                    style: AppStyle.fontStyle.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
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
                                  style:
                                      AppStyle.fontStyle.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: AppColors.taxi, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  'Vaqt: ${DateFormat('yyyy-MM-dd – HH:mm').format(orderTimeInUtcPlus5)}',
                                  style:
                                      AppStyle.fontStyle.copyWith(fontSize: 12),
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
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  backgroundColor: AppColors.taxi,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () => _handleOrderAcceptance(
                                        order.id, orderType),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        'Qabul qilish',
                                        style: AppStyle.fontStyle.copyWith(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}
