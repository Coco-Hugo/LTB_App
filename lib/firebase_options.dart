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
        return android;
      case TargetPlatform.iOS:
        return ios;
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
    apiKey: 'AIzaSyCAnYnUcOyMvbCVQ6itl-3qez_CHP95hcs',
    appId: '1:583775806105:web:944990def65e07712e0e08',
    messagingSenderId: '583775806105',
    projectId: 'lets-talk-business-app',
    authDomain: 'lets-talk-business-app.firebaseapp.com',
    storageBucket: 'lets-talk-business-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdcjnCyTVbILRG6_HEhpXb7ctdO95aRGU',
    appId: '1:583775806105:android:e3ef469e578a4d032e0e08',
    messagingSenderId: '583775806105',
    projectId: 'lets-talk-business-app',
    storageBucket: 'lets-talk-business-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-PoXp2V33EorTpcYCkvBPAORWzORRD8M',
    appId: '1:583775806105:ios:d753e93e513cf7da2e0e08',
    messagingSenderId: '583775806105',
    projectId: 'lets-talk-business-app',
    storageBucket: 'lets-talk-business-app.firebasestorage.app',
    iosBundleId: 'com.example.ltpApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-PoXp2V33EorTpcYCkvBPAORWzORRD8M',
    appId: '1:583775806105:ios:8b6bf8ab822116852e0e08',
    messagingSenderId: '583775806105',
    projectId: 'lets-talk-business-app',
    storageBucket: 'lets-talk-business-app.firebasestorage.app',
    iosBundleId: 'com.example.toonflixFlutterNomad',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCAnYnUcOyMvbCVQ6itl-3qez_CHP95hcs',
    appId: '1:583775806105:web:801bb392bb506f392e0e08',
    messagingSenderId: '583775806105',
    projectId: 'lets-talk-business-app',
    authDomain: 'lets-talk-business-app.firebaseapp.com',
    storageBucket: 'lets-talk-business-app.firebasestorage.app',
  );
}
