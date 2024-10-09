import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namangantoshkent/screens/admin/users_page.dart';
import 'package:namangantoshkent/screens/civil/civil_page.dart';
import 'package:namangantoshkent/screens/drivers/drivers_page.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<bool> isAdmin(String email) async {
    // Access the 'admin' collection and 'user' document
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('admin').doc('user').get();

    // Check if the 'admin' field in the document matches the current user's email
    if (snapshot.exists) {
      String? adminEmail = snapshot.data()?['admin'];
      return adminEmail == email;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return MainCivilPage();
    } else {
      return FutureBuilder<bool>(
        future: isAdmin(user.email!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return UserManagementPage(); // If the user is admin, go to AdminPage
          } else {
            return DriverPage(); // Otherwise, go to DriverPage
          }
        },
      );
    }
  }
}
