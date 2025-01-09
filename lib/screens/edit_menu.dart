import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuModifierPage extends StatefulWidget {
  @override
  _MenuModifierPageState createState() => _MenuModifierPageState();
}

class _MenuModifierPageState extends State<MenuModifierPage> {
  // State variables
  String? selectedDay;
  String? selectedMeal;
  String? selectedCategory;
  String? newItemName;
  Map<String, dynamic> selectedMealData =
      {}; // To store meal data (breakfast, lunch, etc.)

  List<String> daysOfTheWeek = []; // List of days (Monday, Tuesday, ...)
  List<String> mealTypes =
      []; // Meal types for the selected day (breakfast, lunch, ...)
  List<String> categories =
      []; // Categories of the selected meal (Main Dish, Beverages, etc.)
  bool isLoading = true; // Loading state for data fetching

  // Fetch the list of days from Firestore (from 'menus' collection)
  Future<void> _fetchDays() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final menuSnapshot = await firestore.collection('menus').get();

      if (menuSnapshot.docs.isNotEmpty) {
        setState(() {
          daysOfTheWeek = menuSnapshot.docs.map((doc) => doc.id).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching days from Firestore: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch the menu (meal data) for the selected day
  Future<void> _fetchMealData(String day) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final menuSnapshot = await firestore.collection('menus').doc(day).get();

      if (menuSnapshot.exists) {
        Map<String, dynamic> meals =
            menuSnapshot.data() as Map<String, dynamic>;

        setState(() {
          selectedMealData = meals;
          mealTypes = meals.keys
              .toList(); // Populate meal types (e.g., breakfast, lunch, ...)
          selectedMeal = null; // Reset selected meal
          selectedCategory = null; // Reset selected category
          categories = []; // Reset categories list
        });
      }
    } catch (e) {
      print('Error fetching meal data from Firestore: $e');
    }
  }

  // Fetch the categories for the selected meal (e.g., Main Dish, Beverages)
  void _fetchCategories(String meal) {
    setState(() {
      // Get categories from the selected meal and sort them by 'order'
      var mealData = selectedMealData[meal];
      if (mealData != null) {
        categories = (mealData as Map<String, dynamic>).keys.toList()
          ..sort((a, b) {
            int orderA = (mealData[a]['order'] as int?) ?? 0;
            int orderB = (mealData[b]['order'] as int?) ?? 0;
            return orderA.compareTo(orderB);
          });
      }
      selectedCategory = null; // Reset selected category
    });
  }

  // Update the item name in Firestore
  Future<void> _updateItemName(
      String day, String meal, String category, String newName) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Update the 'item' field in the specific category
      await firestore.collection('menus').doc(day).update({
        '$meal.$category.item':
            newName, // Update the 'item' of the specific category
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item name updated successfully')));

      // Clear all fields after successful update
      setState(() {
        selectedDay = null;
        selectedMeal = null;
        selectedCategory = null;
        newItemName = null; // Clear the new item name
        categories = [];
      });
    } catch (e) {
      print('Error updating item name in Firestore: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update item name')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDays(); // Fetch available days when the app starts
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double containerHeight = screenHeight - kBottomNavigationBarHeight - 32.0;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Menu Modifier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : Center(
                child: Container(
                  width: screenWidth * 0.6,
                  height: containerHeight * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Dropdown for selecting the day (Monday, Tuesday, etc.)
                      DropdownButton<String>(
                        hint: Text('Select a Day'),
                        value: selectedDay,
                        onChanged: (day) {
                          setState(() {
                            selectedDay = day;
                            _fetchMealData(
                                day!); // Fetch meals for the selected day
                          });
                        },
                        items: daysOfTheWeek.map((day) {
                          return DropdownMenuItem(value: day, child: Text(day));
                        }).toList(),
                      ),

                      // Dropdown for selecting the meal (Breakfast, Lunch, Snacks, etc.)
                      if (selectedDay != null)
                        DropdownButton<String>(
                          hint: Text('Select a Meal'),
                          value: selectedMeal,
                          onChanged: (meal) {
                            setState(() {
                              selectedMeal = meal;
                              _fetchCategories(
                                  meal!); // Fetch categories for the selected meal
                            });
                          },
                          items: mealTypes.map((meal) {
                            return DropdownMenuItem(
                                value: meal, child: Text(meal));
                          }).toList(),
                        ),

                      // Dropdown for selecting the category (Main Dish, Beverages, etc.)
                      if (selectedMeal != null)
                        DropdownButton<String>(
                          hint: Text('Select a Category'),
                          value: selectedCategory,
                          onChanged: (category) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          items: categories.map((category) {
                            return DropdownMenuItem(
                                value: category, child: Text(category));
                          }).toList(),
                        ),

                      // TextField for modifying the item name
                      if (selectedCategory != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'New Item Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              newItemName = value;
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      // Fixed buttons at the bottom
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context); // Navigate back to the previous screen
                },
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Back"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Text color white
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              // Update Button
              ElevatedButton(
                onPressed: () {
                  if (selectedDay != null &&
                      selectedMeal != null &&
                      selectedCategory != null &&
                      newItemName != null &&
                      newItemName!.isNotEmpty) {
                    // Call the method to update the item name in Firestore
                    _updateItemName(
                      selectedDay!,
                      selectedMeal!,
                      selectedCategory!,
                      newItemName!,
                    );
                  } else {
                    // Show error message if any field is missing
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please check the fields properly')));
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Update"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Text color white
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
