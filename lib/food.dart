import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FoodScreen extends StatefulWidget {
  final String day;

  const FoodScreen({Key? key, required this.day}) : super(key: key);

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> foods = [];

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Convert day string to number for Breakfast
      final dayParam = widget.day == 'Breakfast' ? '1' : widget.day;
      final url = 'https://dasroor.com/lalavqa3a/panel/api/fetch_foods.php?userid=$userId&day=$dayParam';
      print('Request URL: $url'); // Debug request URL

      final response = await http.get(Uri.parse(url));

      print('Response Status Code: ${response.statusCode}'); // Debug response status
      print('Response Body: ${response.body}'); // Debug response body

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          foods = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
        
        // Debug parsed data
        print('Parsed Foods:');
        for (var food in foods) {
          print('Food Name: ${food['food_name']}');
          print('Image: ${food['image']}');
          print('Gram: ${food['gram']}');
          print('Done: ${food['done']}');
          print('-------------------');
        }
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Day ${widget.day} Meals', 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          food['image'] ?? '',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food['food_name'] ?? 'Meal Name',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Portion: ${food['gram'] ?? 'Not specified'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  food['done'] == 1 ? Icons.check_circle : Icons.circle_outlined,
                                  color: food['done'] == 1 ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  food['done'] == 1 ? 'Completed' : 'Not completed',
                                  style: TextStyle(
                                    color: food['done'] == 1 ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
} 