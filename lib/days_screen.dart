import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym/l10n/app_localizations.dart';

class DaysScreen extends StatefulWidget {
  @override
  _DaysScreenState createState() => _DaysScreenState();
}

class _DaysScreenState extends State<DaysScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> days = [];

  @override
  void initState() {
    super.initState();
    fetchDays();
  }

  Future<void> fetchDays() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      final languageCode = Localizations.localeOf(context).languageCode;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://dasroor.com/lalavqa3a/panel/api/fetch_days.php?userid=$userId&lang=$languageCode'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          days = List<Map<String, dynamic>>.from(data);
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Localizations.localeOf(context).languageCode == 'ar' || 
                  Localizations.localeOf(context).languageCode == 'fa';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.workouts, 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/exercises',
                            arguments: days[index]['day'].toString()
                          );
                        },
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: [
                              Colors.blue[50],
                              Colors.purple[100],
                              Colors.teal[100],
                              Colors.pink[50],
                            ][index % 4],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${localizations.day} ${days[index]['day']}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${days[index]['exercises_count'] ?? 15} ${localizations.exercises}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${days[index]['duration'] ?? 45} ${localizations.minutes}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  'https://dasroor.com/lalavqa3a/images/${days[index]['dayimage']}',
                                  width: 120,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 120,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
