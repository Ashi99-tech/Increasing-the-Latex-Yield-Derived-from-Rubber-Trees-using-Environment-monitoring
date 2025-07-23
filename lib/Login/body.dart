// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:rubber_lk/harvest_prediction.dart';
import 'package:rubber_lk/main.dart';
import 'package:rubber_lk/user_profile.dart';
import 'package:rubber_lk/welcome.dart';
import '../Components/already_have_an_account_check.dart';
import '../Components/rounded_password_input_field.dart';
import '../Components/rounded_text_input_field.dart';
import '../Signup/background.dart';
import '../auth.dart';
import '../meter_dashboard.dart';
import '../weather_dashboard.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String? errorMessage = '';
  String email = '';
  String password = '';
  bool isSignedIn = false;
  bool isLoading = false;

  Future<void> signInWithEmailAndPassword() async {
    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        errorMessage = 'Please enter a valid email address';
      });
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setState(() {
        errorMessage = null;
        isSignedIn = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        print(errorMessage);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (ctx) => MyApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "LOGIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: size.height * 0.35,
                ),
              ],
            ),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),

            RoundedInputField(
              hintText: "Your Email",
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),

            RoundedPasswordField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(29),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: size.width * 0.8,
              child: TextButton(
                onPressed: () {
                  signInWithEmailAndPassword();
                },
                child:
                    isLoading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : const Text(
                          "LOGIN",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
              ),
            ),
            if (!isSignedIn)
              AlreadyHaveAnAccountCheck(
                press: () {
                  // Handle navigation or any other action here
                },
              ),
            if (isSignedIn)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(29),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                width: size.width * 0.8,
                child: TextButton(
                  onPressed: () {
                    // Navigate to dashboard.dart DashboardScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WeatherDashboardScreen(),
                      ),
                    );
                  },

                  child: const Text(
                    "WEATHER DASHBOARD",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            if (isSignedIn)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(29),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                width: size.width * 0.8,
                child: TextButton(
                  onPressed: () {
                    // Navigate to dashboard.dart DashboardScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MeterDashboardScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "METER DASHBOARD",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            if (isSignedIn)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(29),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                width: size.width * 0.8,
                child: TextButton(
                  onPressed: () {
                    // Navigate to dashboard.dart DashboardScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HarvestPrediction(),
                      ),
                    );
                  },

                  child: const Text(
                    "HARVEST PREDICTION",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            if (isSignedIn)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(29),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                width: size.width * 0.8,
                child: TextButton(
                  onPressed: () {
                    // Navigate to dashboard.dart DashboardScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Userprofile(),
                      ),
                    );
                  },

                  child: const Text(
                    "CHAT BOT",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            if (isSignedIn)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(29),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                width: size.width * 0.8,
                child: TextButton(
                  onPressed: () {
                    // Navigate to dashboard.dart DashboardScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Userprofile(),
                      ),
                    );
                  },

                  child: const Text(
                    "NEWS & UPDATES",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            if (isSignedIn)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(29),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                width: size.width * 0.8,
                child: TextButton(
                  onPressed: () {
                    // Navigate to dashboard.dart DashboardScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Userprofile(),
                      ),
                    );
                  },

                  child: const Text(
                    "SHOPPING CART",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            if (isSignedIn)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(29),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                width: size.width * 0.8,
                child: TextButton(
                  onPressed: () {
                    // Navigate to dashboard.dart DashboardScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Userprofile(),
                      ),
                    );
                  },

                  child: const Text(
                    "USER PROFILE",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
