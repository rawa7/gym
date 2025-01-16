import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Exercise {
  final int id;
  final String name;
  final int sets;
  final int reps;
  final String customSet;
  final String day;
  final String image;
  int sequence;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.customSet,
    required this.day,
    required this.sequence,
    required this.image,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['userexercise_id'],
      name: json['name'] ?? 'Unnamed Exercise',
      sets: json['sett'] ?? 0,
      reps: json['tkrar'] ?? 0,
      customSet: json['customset'] ?? '',
      day: json['day'].toString() ?? 'Unknown Day',
      sequence: json['sequence'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}

class ExerciseScreen extends StatefulWidget {
  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Exercise> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Retrieve user_id from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      final String day = ModalRoute.of(context)!.settings.arguments as String;

      if (userId == null) {
        print('Error: User ID not found in SharedPreferences');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Make API call using user_id
      final response = await http.get(
        Uri.parse('https://dasroor.com/lalavqa3a/panel/api/fetch_exercises.php?userid=$userId&day=$day'),
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}'); // Debug
        final List<dynamic> jsonResponse = json.decode(response.body);
        
        setState(() {
          exercises = jsonResponse.map((json) => Exercise.fromJson(json)).toList();
          isLoading = false;
        });
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

  Future<void> updateSequence() async {
    final updates = exercises
        .map((e) => {'id': e.id, 'sequence': e.sequence})
        .toList();

    final response = await http.post(
      Uri.parse('https://dasroor.com/lalavqa3a/panel/api/update_exercise_sequence.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update sequence')),
      );
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'WORKOUT',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Workout Summary Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue[100],
                    ),
                    child: Column(
                      children: [
                        // Workout Image
                        GestureDetector(
                          onTap: () {
                            if (exercises.isNotEmpty) {
                              _showFullImage(exercises[0].image);
                            }
                          },
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: exercises.isNotEmpty
                                ? Image.network(
                                    exercises[0].image,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.fitness_center, size: 50),
                                      );
                                    },
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.fitness_center, size: 50),
                                  ),
                          ),
                        ),
                        // Workout Stats
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Total', '${exercises.length} exercises'),
                              _buildStatColumn('Time', '20 min'),
                              _buildStatColumn('Energy you\'ll burn', '250 calories'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Exercise List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return _buildExerciseCard(exercise, index);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: GestureDetector(
          onTap: () => _showFullImage(exercise.image),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              exercise.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  backgroundColor: Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
                  child: const Icon(Icons.fitness_center),
                );
              },
            ),
          ),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Sets: ${exercise.sets} • Reps: ${exercise.reps}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: exercise.sequence == exercises.length
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
