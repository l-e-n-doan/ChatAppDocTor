import 'dart:io';

import 'package:chatapp_firebase/pages/auth/login_page.dart';
import 'package:chatapp_firebase/pages/home_page.dart';
import 'package:chatapp_firebase/service/auth_service.dart';
import 'package:chatapp_firebase/service/database_service.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  String profilePic;
  ProfilePage(
      {Key? key,
      required this.email,
      required this.userName,
      required this.profilePic})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? galleryFile;
  final picker = ImagePicker();
  String password = "";
  String fullName = "";

  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showEditDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 50),
          itemCount: 1, // Đặt số lượng item là 1 nếu bạn chỉ có một hình ảnh
          itemBuilder: (context, index) {
            return Column(
              children: [
                if (widget.profilePic == "null" || widget.profilePic == "")
                  Icon(
                    Icons.account_circle,
                    size: 150,
                    color: Colors.grey[700],
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(75),
                    child: Image.file(
                      File(widget.profilePic),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 15),
                Text(
                  widget.userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(
                  height: 2,
                ),
                ListTile(
                  onTap: () {
                    nextScreen(context, const HomePage());
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(Icons.group),
                  title: const Text(
                    "Groups",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  onTap: () {},
                  selectedColor: Theme.of(context).primaryColor,
                  selected: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(Icons.group),
                  title: const Text(
                    "Profile",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  onTap: () async {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Logout"),
                            content:
                                const Text("Are you sure you want to logout?"),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await authService.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                      (route) => false);
                                },
                                icon: const Icon(
                                  Icons.done,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            );
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          children: [
            if (widget.profilePic == "null" || widget.profilePic == "")
              Icon(
                Icons.account_circle,
                size: 150,
                color: Colors.grey[700],
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.file(
                  File(widget.profilePic),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Full Name:", style: TextStyle(fontSize: 14)),
                Text(widget.userName, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email:", style: TextStyle(fontSize: 14)),
                Text(widget.email, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: textInputDecoration.copyWith(
                    labelText: "Full Name",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    )),
                onChanged: (val) {
                  setState(() {
                    fullName = val;
                  });
                },
                validator: (val) {
                  if (val!.isNotEmpty) {
                    return null;
                  } else {
                    return "Name cannot be empty";
                  }
                },
              ),
              SizedBox(height: 10),
              Text("Avatar"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
                child: const Text('Select Image'),
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
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                editUser();
                Navigator.of(context).pop();
                showSnackbar(context, Colors.green, "Edit user successfully");
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor),
              child: const Text("CONFIRM"),
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
        showEditDialog(context);
      },
    );
  }

  editUser() async {
    String cleanedPath = galleryFile
        .toString()
        .replaceAllMapped(RegExp(r"File: '(.+)'"), (match) => match.group(1)!);
    await DatabaseService().editUser(widget.email, fullName, cleanedPath);
    await authService.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);
  }
}
