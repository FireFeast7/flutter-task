import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterdemo/constants.dart';
import 'package:flutterdemo/helpers.dart';
import 'package:flutterdemo/login.dart';
import 'package:flutterdemo/profile.dart';
import 'package:get/get.dart';

FlutterAppAuth appAuth = const FlutterAppAuth();

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Auth0 auth0;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(DOMAIN, CLIENT_ID);
    errorMessage = '';
    checkExistingTokens();
  }

  Future<void> loginAction() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    try {
      setState(() {
        isBusy = true;
        errorMessage = '';
      });

      final authorizationTokenRequest = AuthorizationTokenRequest(
        CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: issuer,
        scopes: ['openid', 'profile', 'offline_access', 'email'],
        additionalParameters: {
          'audience': 'https://dev-lp6q46q3k22p2rez.us.auth0.com/api/v2/'
        },
      );

      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(authorizationTokenRequest);

      if (result != null) {
        setState(() {
          isBusy = false;
        });

        await secureStorage.write(
          key: 'accessToken',
          value: result.accessToken!,
        );
        await secureStorage.write(
          key: 'refreshToken',
          value: result.refreshToken!,
        );

        if (!loggedIn) {
          Get.offAll(() => Profile(logoutAction));
        }
      }
    } catch (e, s) {
      debugPrint('loginAction error: $e - stack: $s');

      setState(() {
        isBusy = false;
        errorMessage = 'An error occurred during login. Please try again.';
      });
    }
  }

  Future<void> logoutAction() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    await secureStorage.deleteAll();
    Get.offAll(() => Login(loginAction, errorMessage));
    setState(() {
      loggedIn = false;
    });
  }

  bool isBusy = false;
  late String errorMessage;
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth0 Demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: isBusy
              ? const CircularProgressIndicator()
              : loggedIn != false
                  ? Profile(logoutAction)
                  : Login(loginAction, errorMessage),
        ),
      ),
    );
  }

  Future<void> checkExistingTokens() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    String? accessToken = await secureStorage.read(key: 'accessToken');
    String? refreshToken = await secureStorage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      if (isTokenExpired(accessToken)) {
        Get.snackbar("Using Refresh Token", "Access Token Expired");
        await renewAuth();
      }
      setState(() {
        loggedIn = true;
      });
    } else {
      setState(() {
        loggedIn = false;
      });
    }
  }
}
