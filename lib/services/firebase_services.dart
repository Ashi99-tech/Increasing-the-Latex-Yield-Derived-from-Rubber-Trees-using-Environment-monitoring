import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseDatabase database = FirebaseDatabase.instance;

  // Keep your existing getMeterData method for backward compatibility
  Stream<DatabaseEvent> getMeterData() {
    return database.ref('YourExistingPath').onValue;
  }

  // Add a new method specifically for your sensor data
  Stream<DatabaseEvent> getSensorData() {
    return database.ref('Monitoring_System/data').limitToLast(1).onValue;
  }
}
