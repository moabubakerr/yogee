import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBGLpIBh4jP3fVzkONlOxDpBdSXsXojeyM",
            authDomain: "yoogeeapp.firebaseapp.com",
            projectId: "yoogeeapp",
            storageBucket: "yoogeeapp.firebasestorage.app",
            messagingSenderId: "453398507872",
            appId: "1:453398507872:web:843ff4d8173a691c962e05",
            measurementId: "G-E8TVQT0SML"));
  } else {
    await Firebase.initializeApp();
  }
}
