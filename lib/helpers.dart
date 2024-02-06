import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterdemo/constants.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

bool isTokenExpired(String accessToken) {
  // final Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
  bool isExpired = JwtDecoder.isExpired(accessToken);

  DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
  print(expirationDate);
  Duration tokenTime = JwtDecoder.getTokenTime(accessToken);
  print(tokenTime.inMinutes);
  return isExpired;
}

Future<void> renewAuth() async {
  FlutterAppAuth flutterAppAuth = new FlutterAppAuth();
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final String? refreshToken = await secureStorage.read(key: 'refreshToken');
  if (refreshToken != null) {
    final TokenResponse? response = await flutterAppAuth.token(TokenRequest(
      CLIENT_ID,
      AUTH0_REDIRECT_URI,
      issuer: issuer,
      refreshToken: refreshToken,
    ));

    // print('Access Token: ${response!.accessToken}');
    // print('Refresh Token: ${response.refreshToken}');
    await secureStorage.write(
        key: 'refreshToken', value: response!.refreshToken);
    await secureStorage.write(
      key: 'accessToken', value: response.accessToken);
  } else {
    Get.snackbar("Error", "Failed to renew token");
    print('No refresh token found. Perform regular login.');
  }
}
