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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCTSPIcMXkoU6e3mqZBQosarMAenx7z4o0',
    appId: '1:335282106487:web:d663e6ac58b45122485672',
    messagingSenderId: '335282106487',
    projectId: 'chatappfirebase-fc240',
    authDomain: 'chatappfirebase-fc240.firebaseapp.com',
    storageBucket: 'chatappfirebase-fc240.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDimNtNJF7PHJUofUGSnNX4om3IX9Cr5gk',
    appId: '1:335282106487:android:32d62cca6c1bd954485672',
    messagingSenderId: '335282106487',
    projectId: 'chatappfirebase-fc240',
    storageBucket: 'chatappfirebase-fc240.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALmLoWUaF4OcGmXu5a6GH_5LHKnX0WYw8',
    appId: '1:335282106487:ios:e570b81522143010485672',
    messagingSenderId: '335282106487',
    projectId: 'chatappfirebase-fc240',
    storageBucket: 'chatappfirebase-fc240.appspot.com',
    iosBundleId: 'com.example.chatappFirebase',
  );
}
