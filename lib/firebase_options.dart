// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyD_gIK7v7xBmOGjutRwdhTvFqMIkotqd4o',
    appId: '1:651094880398:web:10c34cea0215b371a0d9df',
    messagingSenderId: '651094880398',
    projectId: 'rentxpert-a987d',
    authDomain: 'rentxpert-a987d.firebaseapp.com',
    storageBucket: 'rentxpert-a987d.firebasestorage.app',
    measurementId: 'G-0NNYP2PJSD',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCi4C9C1gl1VHULiR0XajlGv7l9dDF_2GQ',
    appId: '1:651094880398:ios:202391ac132b5493a0d9df',
    messagingSenderId: '651094880398',
    projectId: 'rentxpert-a987d',
    storageBucket: 'rentxpert-a987d.firebasestorage.app',
    androidClientId: '651094880398-l4qh6e2qo9ra7ug6k2catl1b5emqnvmr.apps.googleusercontent.com',
    iosClientId: '651094880398-oirdfedvamd4hi9l57a8b8pqrcmftv2f.apps.googleusercontent.com',
    iosBundleId: 'com.example.rentxpertFlutterWeb',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD_gIK7v7xBmOGjutRwdhTvFqMIkotqd4o',
    appId: '1:651094880398:web:10c34cea0215b371a0d9df',
    messagingSenderId: '651094880398',
    projectId: 'rentxpert-a987d',
    authDomain: 'rentxpert-a987d.firebaseapp.com',
    storageBucket: 'rentxpert-a987d.firebasestorage.app',
    measurementId: 'G-0NNYP2PJSD',
  );
}
