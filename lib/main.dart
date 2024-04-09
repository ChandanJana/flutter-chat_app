import 'package:chat_app/screen/auth_screen.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/screen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

/// Add Firebase SDK to your Flutter app
/// Follow this https://firebase.google.com/docs/flutter/setup?platform=android
/// for Firebase CLI setup
///
/// For push notification
/// https://firebase.google.com/docs/cloud-messaging/flutter/client

void main() async {
  /// WidgetsFlutterBinding is a class in the Flutter framework that handles
  /// the binding between Flutter and the underlying platform (e.g., Android or iOS).
  /// ensureInitialized() is a method of the WidgetsFlutterBinding class.
  /// It checks whether the Flutter framework is already initialized and, if not, initializes it.
  /// This is typically used in the main() function of your Flutter app before
  /// running the runApp() function.
  /// By ensuring that Flutter is initialized before running your app, you
  /// can avoid potential issues that may occur if the framework is not properly set up.
  WidgetsFlutterBinding.ensureInitialized();

  /// initialize firebase for this project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: StreamBuilder(
        /// FirebaseAuth.instance.authStateChanges() will always return value
        /// whenever authentication (signUp, signIn, signOut) data is changed.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const SplashScreen();
          }
          print('snapshot data ${snapshot.data}');
          if (snapshot.hasData) {
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
