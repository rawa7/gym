import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym/l10n/app_localizations.dart';

class Exercise {
  final int id;
  final Map<String, String> name;
  final int sets;
  final int reps;
  final String customSet;
  final String day;
  final String image;
  int sequence;
  bool isCompleted;
  String? completionDate;
  int? completionId;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.customSet,
    required this.day,
    required this.sequence,
    required this.image,
    this.isCompleted = false,
    this.completionDate,
    this.completionId,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final hasCompletionId = json['completion_id'] != null;
    
    // Create name map from the three language fields
    Map<String, String> nameMap = {
      'en': json['name'] ?? 'Unnamed Exercise',
      'ar': json['aname'] ?? json['name'] ?? 'تمرين غير مسمى',
      'fa': json['kname'] ?? json['name'] ?? 'تمرینی بێناو',
    };
    
    return Exercise(
      id: json['userexercise_id'],
      name: nameMap,
      sets: json['sett'] ?? 0,
      reps: json['tkrar'] ?? 0,
      customSet: json['customset'] ?? '',
      day: json['day'].toString(),
      sequence: json['sequence'] ?? 0,
      image: json['image'] ?? '',
      isCompleted: hasCompletionId,
      completionDate: json['completion_date'],
      completionId: json['completion_id'],
    );
  }

  String getLocalizedName(String languageCode) {
    return name[languageCode] ?? name['en'] ?? 'Unnamed Exercise';
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
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      final String day = ModalRoute.of(context)!.settings.arguments as String;
      final String languageCode = Localizations.localeOf(context).languageCode;

      if (userId == null) {
        print('❌ Error: User ID not found in SharedPreferences');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final url = 'https://dasroor.com/lalavqa3a/panel/api/fetch_exercises.php?userid=$userId&day=$day&lang=$languageCode';
      print('URL: $url');

      final response = await http.get(Uri.parse(url));

      print('📥 Received response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        print('✅ Successfully parsed ${jsonResponse.length} exercises');
        
        setState(() {
          exercises = jsonResponse.map((json) => Exercise.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markExerciseComplete(int exerciseId) async {
    try {
      print('🎯 Starting exercise completion process');
      print('Exercise ID: $exerciseId');
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      print('👤 User ID: $userId');

      final requestBody = {
        'user_id': userId,
        'userexercise_id': exerciseId,
      };
      
      print('🚀 Sending completion request:');
      print('URL: https://dasroor.com/lalavqa3a/panel/api/mark_exercise_complete.php');
      print('Headers: ${{'Content-Type': 'application/json'}}');
      print('Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('https://dasroor.com/lalavqa3a/panel/api/mark_exercise_complete.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('\n📥 Received completion response:');
      print('Status code: ${response.statusCode}');
      print('Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed response data: $data');
        
        if (data['status'] == 'success') {
          print('✅ Exercise marked as complete successfully');
          
          // Update the exercise in the list immediately
          setState(() {
            final index = exercises.indexWhere((e) => e.id == exerciseId);
            if (index != -1) {
              exercises[index].isCompleted = true;
              exercises[index].completionDate = DateTime.now().toString().split('.')[0];
              exercises[index].completionId = data['completion_id'];
              print('Updated exercise status:');
              print('- Completed: ${exercises[index].isCompleted}');
              print('- Completion Date: ${exercises[index].completionDate}');
              print('- Completion ID: ${exercises[index].completionId}');
            }
          });
          
        } else {
          print('❌ API returned error status');
          print('Error message: ${data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to mark exercise as complete')),
          );
        }
      } else {
        print('❌ HTTP Error ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to mark exercise as complete');
      }
    } catch (e) {
      print('❌ Exception during completion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error marking exercise as complete. Please try again.')),
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
    final localizations = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isRTL = languageCode == 'ar' || languageCode == 'fa';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            localizations.workouts,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue[100],
                      ),
                      child: Column(
                        children: [
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
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  localizations.workoutSummary,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatColumn(
                                      localizations.totalExercises,
                                      '${exercises.length} ${localizations.exercises}'
                                    ),
                                    _buildStatColumn(
                                      localizations.estimatedTime,
                                      '20 ${localizations.minutes}'
                                    ),
                                    _buildStatColumn(
                                      localizations.energyBurn,
                                      '250 ${localizations.calories}'
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
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
                              exercise.getLocalizedName(languageCode),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${localizations.sets}: ${exercise.sets} • ${localizations.reps}: ${exercise.reps}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                if (exercise.isCompleted && exercise.completionDate != null)
                                  Text(
                                    '${localizations.completedOn}: ${exercise.completionDate}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: exercise.isCompleted
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () => markExerciseComplete(exercise.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.withOpacity(0.1),
                                      foregroundColor: Colors.purple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      localizations.complete,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
}
