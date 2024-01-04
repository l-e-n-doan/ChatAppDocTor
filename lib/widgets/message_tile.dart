import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final DateTime time;

  const MessageTile({
    Key? key,
    required this.message,
    required this.sender,
    required this.sentByMe,
    required this.time,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  String? imageUrl;
  String? fileUrl;

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch the image URL when the widget is initialized
  }

  Future<void> fetchData() async {
    if (widget.message.startsWith('images/')) {
      try {
        final ref = FirebaseStorage.instance.ref().child(widget.message);
        var url = await ref.getDownloadURL();
        // print(url);
        setState(() {
          imageUrl = url;
        });
      } catch (e) {
        // Handle errors, such as if the image doesn't exist
        // print("Error fetching image: $e");
      }
    } else if (widget.message.startsWith('files/')) {
      try {
        final ref = FirebaseStorage.instance.ref().child(widget.message);
        var url = await ref.getDownloadURL();
        // print(url);
        setState(() {
          fileUrl = url;
        });
      } catch (e) {
        // Handle errors, such as if the image doesn't exist
        // print("Error fetching image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                width: 200, // Set the width as per your requirement
                height: 200, // Set the height as per your requirement
                fit: BoxFit.cover,
              )
            else if (fileUrl != null)
              GestureDetector(
                onTap: () {
                  launchFileUrl(fileUrl!);
                },
                child: const Text(
                  "Has been sent a file",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              )
            else
              Text(
                widget.message,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            Text(
              _formatTimestamp(widget.time), // Format and display the timestamp
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
  }

  void launchFileUrl(String fileUrl) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
    } else {
      // Xử lý khi không thể mở đường dẫn
      print('Could not launch $fileUrl');
    }
  }
}
