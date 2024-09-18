// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:namangantoshkent/screens/drivers/voice_managment.dart';
// import 'dart:io';

// import 'package:namangantoshkent/style/app_colors.dart';
// import 'package:namangantoshkent/style/app_style.dart';

// class ChatPage extends StatefulWidget {
//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final ScrollController _scrollController = ScrollController();
//   bool _isRecording = false;
//   double _recordingLevel = 0.0;
//   String? _filePath;
//   Stopwatch _stopwatch = Stopwatch();

//   @override
//   void initState() {
//     super.initState();
//     _initializeRecorder();
//   }

//   void _initializeRecorder() async {
//     await _recorder.openRecorder();
//     if (await Permission.microphone.request().isGranted) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     _scrollController.dispose();
//     _stopwatch.stop();
//     super.dispose();
//   }

//   void _startRecording() async {
//     Directory tempDir = await getTemporaryDirectory();
//     _filePath = '${tempDir.path}/voice_message.aac';

//     _stopwatch.start();

//     await _recorder.startRecorder(
//       toFile: _filePath,
//       codec: Codec.aacADTS,
//     );

//     setState(() {
//       _isRecording = true;
//     });
//   }

//   void _stopRecording() async {
//     await _recorder.stopRecorder();
//     _stopwatch.stop();

//     int duration = _stopwatch.elapsed.inSeconds;
//     _stopwatch.reset();

//     setState(() {
//       _isRecording = false;
//       _recordingLevel = 0.0;
//     });

//     _scrollToBottom();

//     // Run the upload in the background
//     _uploadVoiceMessage(duration);
//   }

//   void _uploadVoiceMessage(int duration) async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .get();

//       final file = File(_filePath!);
//       final fileSize = file.lengthSync();

//       // Upload the file to Firebase Storage
//       String fileName = '${DateTime.now().millisecondsSinceEpoch}.aac';
//       UploadTask uploadTask =
//           FirebaseStorage.instance.ref('voiceMessages/$fileName').putFile(file);

//       TaskSnapshot snapshot = await uploadTask;

//       if (snapshot.state == TaskState.success) {
//         String downloadURL = await snapshot.ref.getDownloadURL();

//         // Store the download URL in Firestore
//         await FirebaseFirestore.instance.collection('chats').add({
//           'text': null,
//           'voiceMessage': downloadURL, // Save the download URL
//           'fileSize': fileSize,
//           'duration': duration,
//           'timestamp': FieldValue.serverTimestamp(),
//           'userId': user.uid,
//           'userName': userDoc['name'] ?? 'Unknown User',
//         });
//       } else {
//         _showSnackBar('Failed to upload voice message.');
//       }
//     } catch (e) {
//       _showSnackBar('Error uploading voice message: $e');
//     }
//   }

//   void _sendTextMessage() async {
//     if (_messageController.text.isNotEmpty) {
//       // Show immediate feedback
//       String tempMessage = _messageController.text;
//       _messageController.clear();
//       _scrollToBottom();

//       // Run the Firestore operation in the background
//       _uploadTextMessage(tempMessage);
//     }
//   }

//   void _uploadTextMessage(String message) async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .get();

//       await FirebaseFirestore.instance.collection('chats').add({
//         'text': message,
//         'voiceMessage': null,
//         'timestamp': FieldValue.serverTimestamp(),
//         'userId': user.uid,
//         'userName': userDoc['name'] ?? 'Unknown User',
//       });
//     } catch (e) {
//       _showSnackBar('Error sending message: $e');
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   Widget _buildRecordingIndicator() {
//     return Container(
//       height: 20,
//       width: _recordingLevel * 5,
//       color: Colors.blue,
//       margin: EdgeInsets.only(right: 10),
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 100),
//         width: _recordingLevel * 5,
//         color: Colors.blue,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: Colors.white,
//             )),
//         backgroundColor: AppColors.taxi,
//         title: Text(
//           'Chat',
//           style: AppStyle.fontStyle.copyWith(
//               color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Background Image
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/back_chat.png', // Replace with your image asset
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Chat Content
//           Column(
//             children: [
//               Expanded(
//                 child: StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection('chats')
//                       .orderBy('timestamp')
//                       .snapshots(),
//                   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (!snapshot.hasData) return CircularProgressIndicator();
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       _scrollToBottom();
//                     });
//                     return ListView.builder(
//                       controller: _scrollController,
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         var message = snapshot.data!.docs[index];
//                         final data = message.data() as Map<String, dynamic>?;

//                         String userName = data?['userName'] ?? 'Unknown User';
//                         String? textMessage = data?['text'];
//                         String? voiceMessage = data?['voiceMessage'];
//                         int? duration = data?['duration'];
//                         int? fileSize = data?['fileSize'];
//                         Timestamp? timestamp = data?['timestamp'];
//                         String timeString = timestamp != null
//                             ? DateFormat('HH:mm').format(timestamp.toDate())
//                             : '';

//                         bool isMe = FirebaseAuth.instance.currentUser!.uid ==
//                             data?['userId'];

//                         return Align(
//                           alignment: isMe
//                               ? Alignment.centerRight
//                               : Alignment.centerLeft,
//                           child: Card(
//                             color: isMe ? Colors.green[50] : Colors.white,
//                             elevation: 5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: isMe
//                                     ? Radius.circular(10)
//                                     : Radius.circular(0),
//                                 bottomRight: isMe
//                                     ? Radius.circular(0)
//                                     : Radius.circular(10),
//                               ),
//                             ),
//                             child: Container(
//                               padding: EdgeInsets.all(10),
//                               constraints: BoxConstraints(
//                                   maxWidth:
//                                       MediaQuery.of(context).size.width * 0.8),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   if (!isMe)
//                                     Text(userName,
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold)),
//                                   if (voiceMessage != null)
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: VoiceMessageWidget(
//                                             path: voiceMessage,
//                                             duration: duration ?? 0,
//                                             fileSize: fileSize ?? 0,
//                                             timeString: timeString,
//                                           ),
//                                         ),
//                                         if (isMe) // Show time for your own messages
//                                           Text(
//                                             timeString,
//                                             style: TextStyle(
//                                               color: Colors.grey,
//                                               fontSize: 10,
//                                             ),
//                                           ),
//                                       ],
//                                     )
//                                   else
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(textMessage ?? ''),
//                                         ),
//                                         if (isMe) // Show time for your own messages
//                                           Text(
//                                             timeString,
//                                             style: TextStyle(
//                                               color: Colors.grey,
//                                               fontSize: 10,
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     if (_isRecording) _buildRecordingIndicator(),
//                     Expanded(
//                       child: TextField(
//                         controller: _messageController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter message',
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.8),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(_isRecording ? Icons.stop : Icons.mic),
//                       onPressed:
//                           _isRecording ? _stopRecording : _startRecording,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.send),
//                       onPressed: _sendTextMessage,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
