import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rubber_lk/Components/myprovider.dart';
import 'package:rubber_lk/auth_state_changes.dart';
import 'firebase_options.dart';

void main() async {
  await _setup();
  runApp(
    ChangeNotifierProvider(create: (_) => MyProvider(), child: const MyApp()),
  );
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthChanges(),
    );
  }
}
