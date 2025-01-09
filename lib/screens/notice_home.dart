import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  TextEditingController _noticeController = TextEditingController();
  bool isEditing = false; // To track if user is editing the notice

  @override
  void initState() {
    super.initState();
    fetchNotice(); // Fetch initial notice on page load
  }

  // Function to fetch notice from Firestore and check the 24-hour condition
  Future<void> fetchNotice() async {
    try {
      var noticeDoc = await FirebaseFirestore.instance
          .collection('home_info')
          .doc('notice_board')
          .get();

      var noticeData = noticeDoc.data();
      if (noticeData != null) {
        DateTime lastModified = (noticeData['timestamp'] as Timestamp).toDate();
        DateTime currentTime = DateTime.now();

        // Check if 24 hours have passed
        if (currentTime.difference(lastModified).inHours >= 24) {
          // Clear the notice if 24 hours have passed
          _noticeController.text = '';
        } else {
          // Otherwise, show the existing notice
          _noticeController.text =
              noticeData['notice'] ?? 'No notices available';
        }
      }
    } catch (e) {
      print("Error fetching notice: $e");
    }
  }

  // Function to update notice in Firestore with the current timestamp
  Future<void> updateNotice() async {
    if (_noticeController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('home_info')
            .doc('notice_board')
            .update({
          'notice': _noticeController.text,
          'timestamp': FieldValue.serverTimestamp(), // Add timestamp on update
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Notice updated successfully!'),
        ));

        setState(() {
          isEditing = false;
        });
      } catch (e) {
        print("Error updating notice: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update notice!'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Set background color to blue
      appBar: AppBar(
        title: Text('Notice Board'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height *
                0.6, // 60% of screen height
            width:
                MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make a Notice',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[50],
                  ),
                ),
                SizedBox(height: 20),
                // TextFormField to display and edit notice
                TextFormField(
                  controller: _noticeController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Enter the notice details here...',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  style: TextStyle(fontSize: 18),
                  enabled: isEditing, // Enable editing if isEditing is true
                ),
                SizedBox(height: 20),
                // ElevatedButton to post/submit notice
                ElevatedButton(
                  onPressed: () {
                    if (isEditing) {
                      // Update notice in Firestore if in edit mode
                      updateNotice();
                    } else {
                      // Allow editing
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
                  child: Text(isEditing ? 'Post Notice' : 'Edit Notice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
