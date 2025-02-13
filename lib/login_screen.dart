import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    checkSavedCredentials();
  }

  Future<void> checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    
    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      setState(() {
        rememberMe = true;
      });
      // Optionally auto-login
      login();
    }
  }

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://dasroor.com/lalavqa3a/panel/api/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          final userId = data['user_id'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setInt('user_id', userId);
          // Save username
          await prefs.setString('username', _emailController.text);

          // Save credentials if remember me is checked
          if (rememberMe) {
            await prefs.setString('email', _emailController.text);
            await prefs.setString('password', _passwordController.text);
          } else {
            await prefs.remove('email');
            await prefs.remove('password');
          }

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error. Please try again later.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection.')),
      );
    }
  }

  Future<void> loginAsGuest() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('user_id', 1); // Set user_id to 1 for guest
      await prefs.setString('username', 'Guest'); // Set username to Guest

      // Clear any saved credentials
      await prefs.remove('email');
      await prefs.remove('password');

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging in as guest. Please try again.')),
      );
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
        body: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage('assets/images/gym_banner.png'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    localizations.avenueGym,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyan, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: localizations.userId,
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.person, color: Colors.cyan),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyan, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: localizations.enterPassword,
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.lock, color: Colors.cyan),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                        fillColor: MaterialStateProperty.all(Colors.cyan),
                      ),
                      Text(
                        localizations.rememberMe,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            localizations.loginButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: isLoading ? null : loginAsGuest,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.cyan),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      localizations.loginAsGuest,
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
