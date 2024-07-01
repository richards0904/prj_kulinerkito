import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prj_kulinerkito/controlers/notification_service.dart';
import 'package:prj_kulinerkito/screens/add_post_screen.dart';
import 'package:prj_kulinerkito/screens/detail_screen_with_id.dart';
import 'package:prj_kulinerkito/screens/favorite_screen.dart';
import 'package:prj_kulinerkito/screens/message.dart';
import 'package:prj_kulinerkito/screens/sign_up_screen.dart';
import 'firebase_options.dart';
import 'package:prj_kulinerkito/screens/sign_in_screen.dart';
import 'package:prj_kulinerkito/screens/home_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notifications Received in background");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotification.init();
  await PushNotification.localNotiInit();
  // await PushNotification.getDeviceToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // handle background notif
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      _handleMessageNavigation(message.data);
    }
  });

  // handle foreground notif
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      PushNotification.showSimpleNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        payload: payloadData,
      );
    }
  });

  // handle terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      _handleMessageNavigation(message.data);
    });
  }
  runApp(const MyApp());
}

void _handleMessageNavigation(Map<String, dynamic> data) {
  String notificationType = data['type'];
  String postId = data['postId'];

  if (notificationType == "login") {
    navigatorKey.currentState!.pushNamed("/profile");
  } else if (notificationType == "comment") {
    navigatorKey.currentState!.pushNamed("/detail", arguments: postId);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuliner Kito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
      navigatorKey: navigatorKey,
      routes: {
        '/homescreen': (context) => const HomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/addpost': (context) => AddPostScreen(),
        '/favorites': (context) => FavoriteScreen(),
        '/message': (context) => Message(),
        '/detail': (context) => DetailScreenWithId(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const MainScreen();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const HomeScreen(),
    AddPostScreen(),
    FavoriteScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.redAccent.shade200,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'Posting',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
