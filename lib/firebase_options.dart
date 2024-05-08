// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAw6dTJ5ZAW0B62v8dM8tSnEq3XBMAD8Yo',
    appId: '1:995038183252:web:53bc8b3d3a0dc6bd5e52c1',
    messagingSenderId: '995038183252',
    projectId: 'kulinerkito-db',
    authDomain: 'kulinerkito-db.firebaseapp.com',
    databaseURL: 'https://kulinerkito-db-default-rtdb.firebaseio.com',
    storageBucket: 'kulinerkito-db.appspot.com',
    measurementId: 'G-M5ENG4FN9D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvLWNYmG2K0CXoJQriwROdT_GVb-_frFQ',
    appId: '1:995038183252:android:dfd2227e12a387a65e52c1',
    messagingSenderId: '995038183252',
    projectId: 'kulinerkito-db',
    databaseURL: 'https://kulinerkito-db-default-rtdb.firebaseio.com',
    storageBucket: 'kulinerkito-db.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDB3V9_YlU6a3IE8VUHObynOOOFQp5LiAo',
    appId: '1:995038183252:ios:3921c779d832adaa5e52c1',
    messagingSenderId: '995038183252',
    projectId: 'kulinerkito-db',
    databaseURL: 'https://kulinerkito-db-default-rtdb.firebaseio.com',
    storageBucket: 'kulinerkito-db.appspot.com',
    iosBundleId: 'com.example.prjKulinerkito',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDB3V9_YlU6a3IE8VUHObynOOOFQp5LiAo',
    appId: '1:995038183252:ios:f556d6b11d5bda9b5e52c1',
    messagingSenderId: '995038183252',
    projectId: 'kulinerkito-db',
    databaseURL: 'https://kulinerkito-db-default-rtdb.firebaseio.com',
    storageBucket: 'kulinerkito-db.appspot.com',
    iosBundleId: 'com.example.prjKulinerkito.RunnerTests',
  );
}
