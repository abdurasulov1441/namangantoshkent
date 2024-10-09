import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .set({
                  'name': _nameController.text,
                  'phone': _phoneController.text,
                });
                Navigator.pushReplacementNamed(context, '/chat');
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
