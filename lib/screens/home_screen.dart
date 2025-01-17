import 'package:Mess/main.dart';
import 'package:Mess/screens/complaint_register.dart';
import 'package:Mess/screens/menu_screen.dart';
import 'package:Mess/screens/sign_in.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables to store fetched data
  Map<String, dynamic> messTimings = {};
  Map<String, dynamic> priceDetails = {};
  Map<String, dynamic> messTimingsWeekEnds = {};
  String notice = ''; // Variable to store fetched notice data

  // Function to fetch mess timings, price details, and notice from Firestore
  Future<void> fetchData() async {
    try {
      // Fetch data from Firestore for mess timings, price details, and notice
      var timingsDoc = await FirebaseFirestore.instance
          .collection('home_info')
          .doc('timings_weekdays')
          .get();
      var priceDoc = await FirebaseFirestore.instance
          .collection('home_info')
          .doc('price_details')
          .get();
      var timingsDocWeekEnd = await FirebaseFirestore.instance
          .collection('home_info')
          .doc('timings_weekends')
          .get();
      var noticeDoc = await FirebaseFirestore.instance
          .collection('home_info')
          .doc('notice_board')
          .get();

      setState(() {
        messTimings = timingsDoc.data() ?? {};
        priceDetails = priceDoc.data() ?? {};
        messTimingsWeekEnds = timingsDocWeekEnd.data() ?? {};
        notice = noticeDoc.data()?['notice'] ??
            'No notices'; // Fetch notice or default text
      });
    } catch (e) {
      // print("Error fetching data: $e");
      print("Error Check your network connectivity");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the screen loads
    MyApp.analytics.logEvent(name: 'app_opened');
  }

  @override
  Widget build(BuildContext context) {
    // Fetch current date and day
    String currentDate = DateTime.now().toString().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Hey IITian',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Menu'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to the menu screen
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Complaint Register'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintRegister()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('Admin'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Display current date and day

            // Notice Board Section
            SizedBox(height: 20),
            Container(
              alignment: AlignmentDirectional.center,
              child: Text(
                "Notice Board",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Notice Board (Fetched from Firestore)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // 70% of screen width
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  color: Color.fromARGB(255, 202, 232, 246),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: notice.isEmpty
                    ? Text(
                        'No notices',
                        style: TextStyle(
                            fontSize: 18, fontStyle: FontStyle.italic),
                      ) // If no notice, show "No notices"
                    : Text(
                        notice,
                        style: TextStyle(fontSize: 18),
                      ), // Display fetched notice
              ),
            ),

            // Separator Line
            SizedBox(height: 20),
            Divider(),
            // Displaying the Image with responsive sizing
            SizedBox(height: 20),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.8, // 80% of screen width
                height: MediaQuery.of(context).size.width *
                    0.5, // 50% of screen width
                child: Image.asset(
                  'assets/image/messhall.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 20),
            Text(
              "Hey IITian! Check out today's mess menu in the Menu bar. If you have any complaints, write them in the Complaint Register. For more info, contact the Mess Council.",
              style: TextStyle(fontSize: 18),
            ),

            // Separator Line
            SizedBox(height: 20),
            Divider(),

            // Mess Timings Section
            SizedBox(height: 20),
            Container(
              alignment: AlignmentDirectional.center,
              child: Text(
                "Mess Timings",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Mess Timings (Fetched from Firestore)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // 70% of screen width
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  color: Color.fromARGB(255, 202, 232, 246),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: messTimings.isEmpty
                    ? CircularProgressIndicator() // Show loader while fetching data
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Weekdays",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Breakfast: ${messTimings['Breakfast'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Lunch: ${messTimings['Lunch'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Snacks: ${messTimings['Snacks'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Dinner: ${messTimings['Dinner'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Weekends",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Breakfast: ${messTimingsWeekEnds['Breakfast'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Lunch: ${messTimingsWeekEnds['Lunch'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Snacks: ${messTimingsWeekEnds['Snacks'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Dinner: ${messTimingsWeekEnds['Dinner'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
              ),
            ),

            // Separator Line
            SizedBox(height: 20),
            Divider(),

            // Payment Section (Fetched from Firestore)
            SizedBox(height: 20),
            Container(
              alignment: AlignmentDirectional.center,
              child: Text(
                "Payment for Unsubscribed Users",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Price Details (Fetched from Firestore)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // 70% of screen width
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 202, 232, 246),
                ),
                child: priceDetails.isEmpty
                    ? CircularProgressIndicator() // Show loader while fetching data
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Breakfast: ₹${priceDetails['Breakfast'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Lunch: ₹${priceDetails['Lunch'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Snacks: ₹${priceDetails['Snacks'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Dinner: ₹${priceDetails['Dinner'] ?? 'Not Available'}",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
