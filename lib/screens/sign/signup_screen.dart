// import 'package:email_validator/email_validator.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:namangantoshkent/services/snack_bar.dart';
// import 'package:namangantoshkent/style/app_colors.dart';
// import 'package:namangantoshkent/style/app_style.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreen();
// }

// class _SignUpScreen extends State<SignUpScreen> {
//   bool isHiddenPassword = true;
//   TextEditingController emailTextInputController = TextEditingController();
//   TextEditingController passwordTextInputController = TextEditingController();
//   TextEditingController passwordTextRepeatInputController =
//       TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     emailTextInputController.dispose();
//     passwordTextInputController.dispose();
//     passwordTextRepeatInputController.dispose();

//     super.dispose();
//   }

//   void togglePasswordView() {
//     setState(() {
//       isHiddenPassword = !isHiddenPassword;
//     });
//   }

//   Future<void> signUp() async {
//     final navigator = Navigator.of(context);

//     final isValid = formKey.currentState!.validate();
//     if (!isValid) return;

//     if (passwordTextInputController.text !=
//         passwordTextRepeatInputController.text) {
//       SnackBarService.showSnackBar(
//         context,
//         'Пароли должны совпадать',
//         true,
//       );
//       return;
//     }

//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailTextInputController.text.trim(),
//         password: passwordTextInputController.text.trim(),
//       );
//     } on FirebaseAuthException catch (e) {
//       print(e.code);

//       if (e.code == 'email-already-in-use') {
//         void _showSnackBar(String message) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(message)),
//             );
//           }
//         }

//         return;
//       } else {
//         void _showSnackBar(String message) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(message)),
//             );
//           }
//         }
//       }
//     }

//     navigator.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         backgroundColor: AppColors.headerColor,
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               Icons.arrow_back,
//               color: AppColors.textColor,
//             )),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(30.0),
//         child: Form(
//           key: formKey,
//           child: Column(
//             children: [
//               Text(
//                 'Yangi Akkaunt Yarating',
//                 style: AppStyle.fontStyle
//                     .copyWith(fontSize: 25, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Image.asset(
//                 'assets/images/set.png',
//                 width: 100,
//                 height: 100,
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 'Qo\'riqlash Xizmati'.toUpperCase(),
//                 style: AppStyle.fontStyle
//                     .copyWith(fontSize: 25, fontWeight: FontWeight.bold),
//               ),
//               Row(
//                 children: [
//                   Text(
//                     'Email',
//                     style: AppStyle.fontStyle
//                         .copyWith(fontWeight: FontWeight.bold),
//                   )
//                 ],
//               ),
//               SizedBox(
//                 height: 5,
//               ),
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
//               TextFormField(
//                 style: TextStyle(color: AppColors.textColor),
//                 autocorrect: false,
//                 controller: passwordTextInputController,
//                 obscureText: isHiddenPassword,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 validator: (value) => value != null && value.length < 6
//                     ? 'Минимум 6 символов'
//                     : null,
//                 decoration: InputDecoration(
//                   border: const OutlineInputBorder(),
//                   hintText: 'Введите пароль',
//                   hintStyle: AppStyle.fontStyle,
//                   suffix: InkWell(
//                     onTap: togglePasswordView,
//                     child: Icon(
//                       isHiddenPassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               TextFormField(
//                 style: TextStyle(color: AppColors.textColor),
//                 autocorrect: false,
//                 controller: passwordTextRepeatInputController,
//                 obscureText: isHiddenPassword,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 validator: (value) => value != null && value.length < 6
//                     ? 'Минимум 6 символов'
//                     : null,
//                 decoration: InputDecoration(
//                   border: const OutlineInputBorder(),
//                   hintText: 'Введите пароль еще раз',
//                   hintStyle: AppStyle.fontStyle,
//                   suffix: InkWell(
//                     onTap: togglePasswordView,
//                     child: Icon(
//                         isHiddenPassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: AppColors.textColor),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.headerColor),
//                 onPressed: signUp,
//                 child: const Center(
//                     child: Text(
//                   'Регистрация',
//                   style: AppStyle.fontStyle,
//                 )),
//               ),
//               const SizedBox(height: 30),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Войти', style: AppStyle.fontStyle),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
