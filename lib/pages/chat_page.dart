import 'dart:io';
import 'dart:math';

import 'package:chatapp_firebase/pages/group_info.dart';
import 'package:chatapp_firebase/service/database_service.dart';
import 'package:chatapp_firebase/widgets/message_tile.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String email;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName,
      required this.email});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

final CollectionReference userCollection =
    FirebaseFirestore.instance.collection("users");

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  File? galleryFile;
  final picker = ImagePicker();
  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            widget.groupName,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(
                      context,
                      GroupInfo(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                        adminName: admin,
                      ));
                },
                icon: const Icon(Icons.info))
          ],
        ),
        body: Stack(
          children: <Widget>[
            chatMessage(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[700],
                //color: Colors.white,
                child: Row(children: [
                  Expanded(
                      child: TextFormField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialogSendImage(context);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons
                              .image, // Sử dụng biểu tượng đính kèm ảnh tại đây
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      pickAndUploadFile(context);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.link,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                      fetchEmailsByGroupId(
                          widget.groupId + '_' + widget.groupName);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.send,
                        color: Colors.white,
                      )),
                    ),
                  )
                ]),
              ),
            )
          ],
        ));
  }

  chatMessage() {
    return Padding(
      padding: EdgeInsets.only(bottom: 100.0),
      child: StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.separated(
                  itemCount: snapshot.data.docs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 0), // Khoảng cách giữa các phần tử
                  itemBuilder: (context, index) {
                    return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender'],
                      time: DateTime.fromMillisecondsSinceEpoch(
                          snapshot.data.docs[index]['time']),
                    );
                  },
                )
              : Container();
        },
      ),
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  showDialogSendImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select image",
          //style: (TextStyle(color: Colors.white)),
          ),
          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
                child: const Text('Select Image',
                style: TextStyle(color: Colors.white),),
                onPressed: () async {
                  showPicker(context: context);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 100.0,
                width: 200.0,
                child: galleryFile == null
                    ? const Center(child: Text('Sorry nothing selected!!'))
                    : Center(child: Image.file(galleryFile!)),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor),
              child: const Text("CANCEL",
              style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () async {
                sendImage();
                fetchEmailsByGroupId(widget.groupId+'_'+widget.groupName);
                Navigator.of(context).pop();
                showSnackbar(context, Colors.green, "Send Image successfully");
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor),
              child: const Text("SEND",
              style: TextStyle(color: Colors.white),),
            )
          ],
        );
      },
    );
  }

  showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
        Navigator.of(context).pop();
        showDialogSendImage(context);
      },
    );
  }

  void sendImage() async {
    String randomString = generateRandomString(10);
    final file = File(galleryFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(
        "images/${widget.groupName}/${widget.userName}/${randomString}.jpg");
    try {
      await ref.putFile(file);
      Map<String, dynamic> chatMessageMap = {
        "message":
            "images/${widget.groupName}/${widget.userName}/${randomString}.jpg",
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
    } catch (e) {
      // ...
    }
  }

  String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final List<String> list = List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    );
    return list.join();
  }

  Future<void> _uploadFile(File file, String nameFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("files/${widget.groupName}/${widget.userName}/${nameFile}");
      await ref.putFile(file);
      Map<String, dynamic> chatMessageMap = {
        "message": "files/${widget.groupName}/${widget.userName}/${nameFile}",
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      print('File uploaded successfully!');
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> pickAndUploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      await _uploadFile(file, result.files.single.name);
    } else {
      // User canceled the file picking
    }
  }

//   Future<void> fetchEmailsByGroupId(String groupId) async {
//     try {
//       // Thực hiện truy vấn để lấy dữ liệu từ Firestore
//       // QuerySnapshot querySnapshot =
//       //     await FirebaseFirestore.instance.collection('users').get();
//  QuerySnapshot querySnapshot =
//           await FirebaseFirestore.instance.collection('users').where('groups' , arrayContains: groupId).get();
//       // Kiểm tra xem có dữ liệu không
//
//       if (querySnapshot.docs.isNotEmpty) {
//         // Lấy danh sách các documents từ QuerySnapshot
//         List<DocumentSnapshot> documents = querySnapshot.docs;

//         // Xử lý dữ liệu từ mỗi document
//         for (DocumentSnapshot document in documents) {
//           Map<String, dynamic> data = document.data() as Map<String, dynamic>;

//           // TODO: Xử lý dữ liệu theo nhu cầu của bạn
//           print(data);
//         }
//       } else {
//         print('No documents found.');
//       }
//     } catch (e) {
//       print('Error fetching data: $e');
//     }
//   }
  Future<void> fetchEmailsByGroupId(String groupId) async {
    try {
      List<String> emails = await getEmailsByGroupId(groupId);
      emails.remove(widget.email);
      // Xử lý mỗi email riêng biệt
      for (String email1 in emails) {
        // TODO: Thực hiện xử lý với từng email tại đây

        print('Processing email: $email1');
        sendEmail(email1);
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<List<String>> getEmailsByGroupId(String groupId) async {
    try {
      QuerySnapshot querySnapshot =
          await userCollection.where('groups', arrayContains: groupId).get();
      List<String> emails = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String? email = data['email'];
        if (email != null) {
          emails.add(email);
        }
      }

      return emails;
    } catch (e) {
      print('Error fetching data: $e');
      return []; // Trả về danh sách rỗng trong trường hợp lỗi
    }
  }

  Future<void> sendEmail(String email) async {
  final apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  String toEmail = email;
  
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Origin': 'https://your-flutter-app-domain.com',
    },
    body: '''
    {
      "service_id": "service_lmdm2uf",
      "template_id": "template_jtshxnh",
      "user_id": "Jj4f9wmsqF6zRRQka",
      "template_params": {
        "to_email": "$toEmail",
        "subject": "Test Email",
        "body": "This is a test email sent from a Flutter web app."
      }
    }
  ''',
  );

  if (response.statusCode == 200) {
    print('Email sent successfully');
  } else {
    print('Failed to send email. Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
//  Future<void> fetchEmailsByGroupId(groupId) async {
//     try {
//       QuerySnapshot querySnapshot = await userCollection.where('groups', arrayContains: groupId).get();
//       List<String> emails = [];

//       for (var doc in querySnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         String? email = data['email'];
//         if (email != null) {
//           emails.add(email);
//         }
//       }

//       // TODO: Xử lý danh sách email
//       print('Emails in group $groupId, $emails');

//     } catch (e) {
//       print('Error fetching data: $e');
//     }
//   }
}
