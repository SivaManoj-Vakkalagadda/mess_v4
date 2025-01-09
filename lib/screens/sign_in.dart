import 'package:Mess/screens/edit_menu.dart';
import 'package:Mess/screens/notice_home.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false; // Track the visibility of the password

  // Function to handle sign-in
  void signIn() async {
    String userId = userIdController.text.trim(); // User ID (email)
    String password = passwordController.text.trim(); // Password

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in both fields")),
      );
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      // Fetch the password from Firestore using the userId (email)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc('user_details')
          .get();

      // Check if the document exists
      if (userDoc.exists) {
        // Fetch the password stored under the user_id (email)
        String storedPassword = userDoc[userId];

        // Check if the password matches
        if (storedPassword != null && storedPassword == password) {
          // Success! Redirect to another page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuccessPage()),
          );
        } else {
          // Invalid credentials
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User details not matched")),
          );
        }
      } else {
        // User details document not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User details not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        // SnackBar(content: Text("Error: $e")),
        SnackBar(content: Text("Please check your network Connectivity")),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });

      // Clear the text fields after the attempt
      userIdController.clear();
      passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size to adjust the container size
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Sign In"),
      ),
      body: Container(
        color: Colors.blue[50], // Light blue background color for contrast
        child: Center(
          child: Container(
            height: screenHeight * 0.6, // 60% of screen height
            width: screenWidth * 0.8, // 80% of screen width
            decoration: BoxDecoration(
              color: Colors.white, // White background for the container
              borderRadius: BorderRadius.circular(16), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[75], // Change text color to blue
                  ),
                ),
                SizedBox(height: 40),

                // User ID (Email) Text Field
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    labelText: "User ID (Email)",
                    hintText: "Enter your email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // Password Text Field with a visibility toggle
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible, // Toggle password visibility
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible =
                              !isPasswordVisible; // Toggle visibility
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // Sign In Button
                ElevatedButton(
                  onPressed: signIn,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Sign In"),
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen size to adjust the container size
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Access"),
      ),
      backgroundColor:
          Colors.blue[50], // Light blue background color for contrast
      body: Center(
        child: Container(
          height: screenHeight * 0.6, // 60% of screen height
          width: screenWidth * 0.8, // 80% of screen width
          decoration: BoxDecoration(
            color: Colors.white, // White background for the container
            borderRadius: BorderRadius.circular(16), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hello Admin!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[75],
                ),
              ),
              SizedBox(height: 30),

              // Button that redirects to Menu Modifier Page
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuModifierPage()),
                  );
                },
                child: Text('Edit Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50], // Button color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20), // Add some space
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NoticePage()),
                  );
                },
                child: Text('Post Notice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50], // Button color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
