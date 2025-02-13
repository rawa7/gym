import 'package:flutter/material.dart';
import 'package:gym/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:gym/language_selector.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class CarouselItem {
  final String imageUrl;

  CarouselItem({
    required this.imageUrl,
  });

  factory CarouselItem.fromString(String url) {
    return CarouselItem(
      imageUrl: url,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? username;
  List<CarouselItem> carouselItems = [];
  bool isLoadingCarousel = true;
  Map<String, int> statistics = {
    'exercises_today': 0,
    'training_days_this_month': 0,
    'total_points_this_month': 0,
  };
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchStatistics();
    _fetchCarouselData();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      isLoadingStats = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        print('❌ User ID not found');
        return;
      }

      print('\n🔍 Fetching statistics:');
      print('URL: https://dasroor.com/lalavqa3a/panel/api/get_statistics.php');
      print('User ID: $userId');
      
      final requestBody = json.encode({'user_id': userId});
      print('Request Body: $requestBody');
      print('Headers: ${{'Content-Type': 'application/json'}}');

      final response = await http.post(
        Uri.parse('https://dasroor.com/lalavqa3a/panel/api/home.php'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('\n📥 Received response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('\n✅ Parsed response data:');
        print('Status: ${data['status']}');
        if (data['status'] == 'success') {
          print('Statistics:');
          print('- Exercises today: ${data['data']['exercises_today']}');
          print('- Training days this month: ${data['data']['training_days_this_month']}');
          print('- Total points this month: ${data['data']['total_points_this_month']}');
          
          setState(() {
            statistics = {
              'exercises_today': data['data']['exercises_today'],
              'training_days_this_month': data['data']['training_days_this_month'],
              'total_points_this_month': data['data']['total_points_this_month'],
            };
          });
        } else {
          print('❌ API returned error status');
          print('Error message: ${data['message']}');
        }
      } else {
        print('❌ HTTP Error ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching statistics: $e');
    } finally {
      setState(() {
        isLoadingStats = false;
      });
    }
  }

  Future<void> _fetchCarouselData() async {
    setState(() {
      isLoadingCarousel = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        print('❌ User ID not found');
        return;
      }

      print('\n🔍 Fetching carousel data:');
      final response = await http.post(
        Uri.parse('https://dasroor.com/lalavqa3a/panel/api/get_carousel.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      print('\n📥 Received carousel response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            carouselItems = (data['data'] as List)
                .map((url) => CarouselItem.fromString(url.toString()))
                .toList();
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching carousel data: $e');
    } finally {
      setState(() {
        isLoadingCarousel = false;
      });
    }
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<void> logout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).logout),
        content: Text(AppLocalizations.of(context).logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).yes),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all saved preferences
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/exercises');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Localizations.localeOf(context).languageCode == 'ar' || 
                  Localizations.localeOf(context).languageCode == 'ku';
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LanguageSelector(),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_library),
                            onPressed: () => Navigator.pushNamed(context, '/gallery'),
                            tooltip: 'Gallery',
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () => logout(context),
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.hello,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                  ),
                  FutureBuilder<int>(
                    future: getUserId(),
                    builder: (context, snapshot) {
                      return Text(
                        username ?? 'User',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  isLoadingCarousel
                      ? Container(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : carouselItems.isEmpty
                          ? Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/gym_banner.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : FlutterCarousel(
                              options: CarouselOptions(
                                height: 200,
                                viewportFraction: 1.0,
                                showIndicator: true,
                                slideIndicator: CircularSlideIndicator(
                                  slideIndicatorOptions: SlideIndicatorOptions(
                                    currentIndicatorColor: Colors.white,
                                    indicatorBackgroundColor: Colors.grey,
                                    indicatorRadius: 4,
                                    itemSpacing: 12,
                                  ),
                                ),
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                enableInfiniteScroll: true,
                                autoPlayCurve: Curves.fastOutSlowIn,
                                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              ),
                              items: carouselItems.map((item) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          image: NetworkImage(item.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.weeklyStats,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  isLoadingStats
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/days'),
                                    child: _StatCard(
                                      title: statistics['exercises_today'].toString(),
                                      subtitle: localizations.todayexercises,
                                      icon: Icons.fitness_center,
                                      color: Colors.orange[100]!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _StatCard(
                                    title: statistics['training_days_this_month'].toString(),
                                    subtitle: localizations.daysThisMonth,
                                    icon: Icons.calendar_month,
                                    color: Colors.green[100]!,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _StatCard(
                              title: statistics['total_points_this_month'].toString(),
                              subtitle: localizations.totalCrusts,
                              icon: Icons.star,
                              color: Colors.blue[100]!,
                              fullWidth: true,
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              localizations.tryCelebrity,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {},
            child: Text(localizations.letsTry),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              localizations.skip,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
