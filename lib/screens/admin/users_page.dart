import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namangantoshkent/style/app_colors.dart';
import 'package:namangantoshkent/style/app_style.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  bool _isLoading = false;

  Future<void> _addUser(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить пользователя'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return _isLoading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          String email = emailController.text.trim();
                          if (!email.contains('@')) {
                            email = '$email@gmail.com';
                          }
                          final password = passwordController.text.trim();
                          final DateTime initialExpiryDate =
                              DateTime.now().add(const Duration(days: 30));

                          try {
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userCredential.user!.uid)
                                .set({
                              'email': email,
                              'uid': userCredential.user!.uid,
                              'disabled': false,
                              'expiry_date': initialExpiryDate,
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Пользователь добавлен')),
                              );
                              Navigator.pop(context);
                            }
                          } on FirebaseAuthException catch (e) {
                            String message;
                            if (e.code == 'email-already-in-use') {
                              message = 'Этот email уже используется';
                            } else {
                              message = 'Ошибка: ${e.message}';
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        child: const Text('Добавить'),
                      );
              },
            ),
          ],
        );
      },
    );
  }

  void _updateExpiryDate(String userId, int days) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await docRef.get();

    if (userDoc.exists) {
      final expiryDate =
          userDoc['expiry_date'].toDate().add(Duration(days: days));
      await docRef.update({'expiry_date': expiryDate});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.taxi,
        title: Text(
          'Управление Пользователями',
          style: AppStyle.fontStyle.copyWith(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => _addUser(context),
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id;
              final email = user['email'];
              final isDisabled = user['disabled'] ?? false;
              final expiryDate = user['expiry_date'].toDate();
              final remainingDays =
                  expiryDate.difference(DateTime.now()).inDays;

              return ListTile(
                title: Text(email),
                subtitle: Text(
                  'Осталось дней: $remainingDays',
                  style: TextStyle(
                      color: remainingDays <= 0 ? Colors.red : Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .delete(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateExpiryDate(userId, -30),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateExpiryDate(userId, 30),
                    ),
                    IconButton(
                      icon: Icon(
                        isDisabled ? Icons.lock_open : Icons.lock,
                        color: isDisabled ? Colors.green : Colors.red,
                      ),
                      onPressed: () => FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                        'disabled': !isDisabled,
                      }),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
