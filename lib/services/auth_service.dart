import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<User?> signInWithKakao() async {
    try {
      // Kakao Login
      // print('Starting Kakao login...');
      bool kakaoTalkInstalled = await kakao.isKakaoTalkInstalled();

      final token = kakaoTalkInstalled
          ? await kakao.UserApi.instance.loginWithKakaoTalk()
          : await kakao.UserApi.instance.loginWithKakaoAccount();

      // print('Kakao login successful');

      // Get Kakao user info
      final kakaoUser = await kakao.UserApi.instance.me();
      // print('Kakao user ID: ${kakaoUser.id}');

      // Prepare data for Firebase function
      // If your function expects the data directly, keep it like this:
      // If your function was changed to require nesting inside "data", you'd have to do:
      // {'data': { 'uid': ..., 'displayName': ..., ... }}
      // But based on your logs, the top-level map works fine.
      final Map<String, dynamic> data = {
        'uid': kakaoUser.id.toString(),
        'displayName': kakaoUser.kakaoAccount?.profile?.nickname,
        'photoURL': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        'email': kakaoUser.kakaoAccount?.email,
      };

      // print('Calling Firebase function with data: $data');

      // Call Firebase function with explicit timeout
      final callable = _functions.httpsCallable(
        'createCustomToken',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      final result = await callable.call(data);
      // print('Firebase function response: ${result.data}');

      if (result.data == null || !result.data.containsKey('token')) {
        throw Exception(
            'Invalid response from Firebase function: ${result.data}');
      }

      final tokenFromFirebase = result.data['token'] as String;
      // print('Custom token received: $tokenFromFirebase');

      // Sign in to Firebase
      try {
        final credential =
            await _firebaseAuth.signInWithCustomToken(tokenFromFirebase);
        // print('Firebase sign in successful');
        return credential.user;
      } catch (signInError, signInStack) {
        // print('Error signing in with custom token: $signInError');
        // print('Stack trace: $signInStack');
        rethrow;
      }
    } catch (e, stackTrace) {
      // print('Error in signInWithKakao: $e');
      // print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await kakao.UserApi.instance.unlink();
    await _firebaseAuth.signOut();
  }
}
