import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert' as convert;
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintRegister extends StatefulWidget {
  const ComplaintRegister({super.key});

  @override
  _ComplaintRegisterState createState() => _ComplaintRegisterState();
}

class _ComplaintRegisterState extends State<ComplaintRegister> {
  bool isSubmitting = false; // Flag for loading indicator

  String URL = ""; // URL to send complaints to

  // Fetch URL data from Firestore
  Future<void> fetchData() async {
    try {
      var excel_url = await FirebaseFirestore.instance
          .collection('home_info')
          .doc('excel_url')
          .get();

      setState(() {
        // Make sure to access the 'url' key correctly
        URL = excel_url.data()?['url'] ??
            ''; // Default to an empty string if not available
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Controllers for the text fields
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();

  // Function to handle form submission
  void _submitForm(
      BuildContext context,
      TextEditingController rollNoController,
      TextEditingController emailController,
      TextEditingController complaintController) {
    if (URL.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL is not available!')),
      );
      return;
    }

    String tempRollNo = rollNoController.text;
    String tempEmail = emailController.text;
    String tempComplaint = complaintController.text;

    if (tempRollNo.isEmpty || tempEmail.isEmpty || tempComplaint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Set isSubmitting to true when the request starts
    setState(() {
      isSubmitting = true;
    });

    String queryString =
        "?email_id=$tempEmail&roll_number=$tempRollNo&complaint=$tempComplaint";
    var finalURI = Uri.parse(URL + queryString);

    // Performing the network request
    http.get(finalURI).then((response) {
      setState(() {
        isSubmitting = false; // Reset the loading state
      });

      if (response.statusCode == 200) {
        var bodyR = convert.jsonDecode(response.body);
        print(bodyR);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted successfully!')),
        );

        // Clear the form after submission
        rollNoController.clear();
        emailController.clear();
        complaintController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit complaint!')),
        );
      }
    }).catchError((e) {
      setState(() {
        isSubmitting = false; // Reset the loading state on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch URL from Firestore when the page loads
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double horizontalPadding = screenWidth * 0.1; // 10% of screen width
    double verticalPadding = screenHeight * 0.1; // 10% of screen height

    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint Register"),
      ),
      body: Container(
        color: Colors.blue[50], // Light blue background color for contrast
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: screenWidth * 0.8, // 80% of the screen width
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the container
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                      16.0), // Padding inside the container
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Roll No input field
                      TextField(
                        controller: rollNoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Roll No",
                          hintText: "Enter your Roll Number",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20), // Space between fields

                      // Email input field
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email ID",
                          hintText: "Enter your Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20), // Space between fields

                      // Complaint input field
                      TextField(
                        controller: complaintController,
                        keyboardType: TextInputType.text,
                        maxLines: 5, // Allow multi-line input for complaints
                        decoration: InputDecoration(
                          labelText: "Complaint",
                          hintText: "Describe your complaint",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20), // Space for submit button

                      // Submit Button
                      ElevatedButton(
                        onPressed: () => _submitForm(
                          context,
                          rollNoController,
                          emailController,
                          complaintController,
                        ),
                        child: isSubmitting
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                  SizedBox(width: 10),
                                  Text("Submitting..."),
                                ],
                              )
                            : Text("Submit"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
