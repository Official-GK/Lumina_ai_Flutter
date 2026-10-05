// lib/firebase_options.dart — Auto-generated from Firebase project: ai-career--skill

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBYSvEPAqJBE5SSqyi32NX4J8bwPMEobUI',
    appId: '1:996856236262:web:b40a83b0a2a70cd52b5327',
    messagingSenderId: '996856236262',
    projectId: 'ai-career--skill',
    authDomain: 'ai-career--skill.firebaseapp.com',
    storageBucket: 'ai-career--skill.firebasestorage.app',
    measurementId: 'G-WD4YBR2YWN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYSvEPAqJBE5SSqyi32NX4J8bwPMEobUI',
    appId: '1:996856236262:android:e8c5c1ee79549ace2b5327',
    messagingSenderId: '996856236262',
    projectId: 'ai-career--skill',
    storageBucket: 'ai-career--skill.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBYSvEPAqJBE5SSqyi32NX4J8bwPMEobUI',
    appId: '1:996856236262:ios:6e97521cd94d16d12b5327',
    messagingSenderId: '996856236262',
    projectId: 'ai-career--skill',
    storageBucket: 'ai-career--skill.firebasestorage.app',
    iosBundleId: 'com.example.luminaCareer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBYSvEPAqJBE5SSqyi32NX4J8bwPMEobUI',
    appId: '1:996856236262:ios:6e97521cd94d16d12b5327',
    messagingSenderId: '996856236262',
    projectId: 'ai-career--skill',
    storageBucket: 'ai-career--skill.firebasestorage.app',
    iosBundleId: 'com.example.luminaCareer',
  );
}
