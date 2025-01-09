import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedDayIndex =
      getCurrentDayAsInt(); // Automatically set to today's day
  Map<String, dynamic> todaysMenu = {}; // To store the fetched menu data
  final List<String> daysOfTheWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  bool isLoading = true;

  // Function to update selected day and fetch data from Firebase
  void _onDaySelected(int index) async {
    setState(() {
      selectedDayIndex = index;
      isLoading = true;
    });

    String day = daysOfTheWeek[selectedDayIndex];
    await _fetchMenuForDay(day);
  }

  // Function to fetch menu for the selected day from Firestore
  Future<void> _fetchMenuForDay(String day) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentSnapshot menuSnapshot =
          await firestore.collection('menus').doc(day).get();

      if (menuSnapshot.exists) {
        // Extracting the meals from the Firestore document
        Map<String, dynamic> meals =
            menuSnapshot.data() as Map<String, dynamic>;

        setState(() {
          // Manually handle the conversion from LinkedMap<dynamic, dynamic> to Map<String, dynamic>
          todaysMenu = {
            'breakfast': _convertToSortedMap(meals['breakfast']),
            'lunch': _convertToSortedMap(meals['lunch']),
            'snacks': _convertToSortedMap(meals['snacks']),
            'dinner': _convertToSortedMap(meals['dinner']),
          };
          isLoading = false; // Stop loading
        });
      } else {
        throw 'No menu data found for $day';
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print('Error fetching menu from Firestore: $e');
      print('Error: Please check your Internet and try again');
      ScaffoldMessenger.of(context)
          // .showSnackBar(SnackBar(content: Text('Error: $e')));
          .showSnackBar(SnackBar(
              content: Text('Error: Please check your network and try again')));
    }
  }

  // Helper function to convert and sort LinkedMap<dynamic, dynamic> to Map<String, String>
  Map<String, String> _convertToSortedMap(dynamic data) {
    if (data is Map) {
      Map<String, dynamic> map = Map<String, dynamic>.from(data);

      // Sort the map entries by 'order' key
      var sortedEntries = map.entries.toList()
        ..sort((a, b) => (a.value['order'] as int).compareTo(b.value['order']));

      Map<String, String> sortedMap = {};
      for (var entry in sortedEntries) {
        sortedMap[entry.key] =
            entry.value['item'] ?? 'No item'; // Using the 'item' field
      }
      return sortedMap;
    }
    return {};
  }

  @override
  void initState() {
    super.initState();
    String currentDay = daysOfTheWeek[selectedDayIndex];
    _fetchMenuForDay(currentDay); // Fetch today's menu on initial load
  }

  @override
  Widget build(BuildContext context) {
    String currentDate =
        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double horizontalPadding = screenWidth * 0.1; // 10% of screen width
    double verticalPadding = screenHeight * 0.1; // 10% of screen height

    // Fallback if no data is fetched yet
    if (todaysMenu.isEmpty) {
      todaysMenu = {
        'breakfast': {'Main Dish': 'Loading...', 'Add On': 'Loading...'},
        'lunch': {'Main Dish': 'Loading...'},
        'snacks': {'Main Snack': 'Loading...'},
        'dinner': {'Curry': 'Loading...'}
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu',
            style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              children: <Widget>[
                // Display current date
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 230, 240, 255),
                  ),
                  child: Center(
                    child: Text(
                      currentDate,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ),
                ),
                // Day buttons bar
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        return ElevatedButton(
                          onPressed: () => _onDaySelected(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedDayIndex == index
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                          child: Text(
                            daysOfTheWeek[index],
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // Meal sections
                _buildMealSection('Breakfast', 'breakfast'),
                _buildMealSection('Lunch', 'lunch'),
                _buildMealSection('Snacks', 'snacks'),
                _buildMealSection('Dinner', 'dinner'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build each meal section dynamically
  Widget _buildMealSection(String mealTitle, String mealType) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: MealHeading(mealTitle),
          padding: EdgeInsets.all(20.0),
        ),
        _buildMealTable(mealType, todaysMenu[mealType]),
      ],
    );
  }

  // Function to build the meal table dynamically
  Widget _buildMealTable(String mealType, Map<String, String> mealItems) {
    if (mealItems == null || mealItems.isEmpty) {
      return Center(child: Text('No data available'));
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double firstColumnWidth = 0.3 * screenWidth;
    double secondColumnWidth = 0.5 * screenWidth;

    return Container(
      color: Color.fromARGB(255, 230, 240, 255),
      child: Table(
        border: TableBorder.all(
            borderRadius: BorderRadius.circular(12), color: Colors.blue),
        columnWidths: {
          0: FixedColumnWidth(firstColumnWidth),
          1: FixedColumnWidth(secondColumnWidth),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Category',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            fontSize: 18)),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Items',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
          for (var category in mealItems.keys)
            TableRow(children: [
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(category,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(mealItems[category] ?? 'No data',
                        style: TextStyle(fontSize: 16.0)),
                  ),
                ),
              ),
            ]),
        ],
      ),
    );
  }
}

// Heading Widget for meals
Widget MealHeading(String heading) {
  return Text(
    heading,
    style: TextStyle(
        fontSize: 22.0, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
  );
}

// Helper functions for current date
int getCurrentDayAsInt() {
  return DateTime.now().weekday - 1; // Convert to 0-based index
}
