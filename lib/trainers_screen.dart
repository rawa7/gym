import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Trainer {
  final String id;
  final String image;
  final Map<String, String> name;
  final Map<String, String> description;
  final Map<String, String> slogan;

  Trainer({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.slogan,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['id'].toString(),
      image: json['image'] ?? '',
      name: Map<String, String>.from(json['name']),
      description: Map<String, String>.from(json['description']),
      slogan: Map<String, String>.from(json['slogan']),
    );
  }

  String getLocalizedName(String languageCode) {
    // Map 'fa' to 'ku' for Kurdish content
    final code = languageCode == 'fa' ? 'ku' : languageCode;
    return name[code] ?? name['en'] ?? 'Unknown Trainer';
  }

  String getLocalizedSlogan(String languageCode) {
    // Map 'fa' to 'ku' for Kurdish content
    final code = languageCode == 'fa' ? 'ku' : languageCode;
    return slogan[code] ?? slogan['en'] ?? 'Professional Trainer';
  }

  String getLocalizedDescription(String languageCode) {
    // Map 'fa' to 'ku' for Kurdish content
    final code = languageCode == 'fa' ? 'ku' : languageCode;
    return description[code] ?? description['en'] ?? '';
  }
}

class TrainersScreen extends StatefulWidget {
  @override
  _TrainersScreenState createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  List<Trainer> trainers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        print('❌ User ID not found');
        return;
      }

      print('\n🔍 Fetching trainers:');
      print('URL: https://dasroor.com/lalavqa3a/panel/api/get_trainers.php');
      print('User ID: $userId');

      final requestBody = json.encode({'user_id': userId});
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('https://dasroor.com/lalavqa3a/panel/api/get_trainers.php'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('\n📥 Received response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            trainers = (data['data'] as List)
                .map((trainer) => Trainer.fromJson(trainer))
                .toList();
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching trainers: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showTrainerDetails(BuildContext context, Trainer trainer) {
    final languageCode = Localizations.localeOf(context).languageCode;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      trainer.image,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Colors.grey[300],
                          child: Icon(Icons.person, size: 50),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainer.getLocalizedName(languageCode),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      trainer.getLocalizedSlogan(languageCode),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      trainer.getLocalizedDescription(languageCode),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Our Trainers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : trainers.isEmpty
              ? Center(
                  child: Text(
                    'No trainers available',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: trainers.length,
                  itemBuilder: (context, index) {
                    final trainer = trainers[index];
                    return GestureDetector(
                      onTap: () => _showTrainerDetails(context, trainer),
                      child: Card(
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                trainer.image,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.person, size: 50),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trainer.getLocalizedName(languageCode),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    trainer.getLocalizedSlogan(languageCode),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 