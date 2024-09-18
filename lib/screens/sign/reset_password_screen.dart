// import 'package:email_validator/email_validator.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:namangantoshkent/services/snack_bar.dart';
// import 'package:namangantoshkent/style/app_colors.dart';
// import 'package:namangantoshkent/style/app_style.dart';


// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   TextEditingController emailTextInputController = TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     emailTextInputController.dispose();

//     super.dispose();
//   }

//   Future<void> resetPassword() async {
//     final navigator = Navigator.of(context);
//     final scaffoldMassager = ScaffoldMessenger.of(context);

//     final isValid = formKey.currentState!.validate();
//     if (!isValid) return;

//     try {
//       await FirebaseAuth.instance
//           .sendPasswordResetEmail(email: emailTextInputController.text.trim());
//     } on FirebaseAuthException catch (e) {
//       print(e.code);

//       if (e.code == 'user-not-found') {
//         SnackBarService.showSnackBar(
//           context,
//           'Такой email незарегистрирован!',
//           true,
//         );
//         return;
//       } else {
//         SnackBarService.showSnackBar(
//           context,
//           'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
//           true,
//         );
//         return;
//       }
//     }

//     const snackBar = SnackBar(
//       content: Text('Сброс пароля осуществен. Проверьте почту'),
//       backgroundColor: Colors.green,
//     );

//     scaffoldMassager.showSnackBar(snackBar);

//     navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         backgroundColor: AppColors.headerColor,
//         title: const Text(
//           'Сброс пароля',
//           style: AppStyle.fontStyle,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(30.0),
//         child: Form(
//           key: formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 style: TextStyle(color: AppColors.textColor),
//                 keyboardType: TextInputType.emailAddress,
//                 autocorrect: false,
//                 controller: emailTextInputController,
//                 validator: (email) =>
//                     email != null && !EmailValidator.validate(email)
//                         ? 'Введите правильный Email'
//                         : null,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: 'Введите Email',
//                   hintStyle: AppStyle.fontStyle,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.headerColor),
//                 onPressed: resetPassword,
//                 child: const Center(
//                     child: Text(
//                   'Сбросить пароль',
//                   style: AppStyle.fontStyle,
//                 )),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
