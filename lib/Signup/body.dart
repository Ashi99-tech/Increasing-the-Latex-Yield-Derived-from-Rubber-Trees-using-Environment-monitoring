// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:rubber_lk/main.dart';

import '../Components/already_have_an_account_check.dart';
import '../Components/rounded_password_input_field.dart';
import '../Components/rounded_text_input_field.dart';
import '../Login/background.dart';
import '../Login/login_screen.dart';
import '../auth.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String? errorMessege;
  String? successMessage;
  String email = '';
  String password = '';
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  bool isLoading = false;

  Future<void> signUpWithEmailAndPassword() async {
    if (password.length < 6) {
      setState(() {
        errorMessege = 'Password must be at least 6 characters';
        successMessage = null;
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        errorMessege = 'Please enter a valid email address';
        successMessage = null;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      setState(() {
        errorMessege = null;
        successMessage = 'Account created successfully';
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Loginscreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          errorMessege = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessege = 'The account already exists for that email.';
        } else {
          errorMessege = e.toString();
        }
        successMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessege = e.toString();
        successMessage = null;
      });
    } finally {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (ctx) => MyApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "SIGNUP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset("assets/images/logo.png", height: size.height * 0.35),
              if (errorMessege != null)
                Text(errorMessege!, style: const TextStyle(color: Colors.red)),
              if (successMessage != null)
                Text(
                  successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                width: size.width * 0.8,
                child: TextButton(
                  onPressed: () {
                    signUpWithEmailAndPassword();
                  },
                  child:
                      isLoading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            "SIGNUP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 15),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Loginscreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              const OrDivider(),
              const SizedBox(height: 15),
              const Text(
                "Please fill details",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(width: size.width * 0.8, child: const Divider());
  }
}
