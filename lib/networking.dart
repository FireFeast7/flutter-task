import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterdemo/constants.dart';
import 'package:flutterdemo/helpers.dart';

Future<void> askingAuth() async {
  Dio dio = Dio();
  String clientId = "o42zwYlHw6EmbRlAkxCwgNQ8vA2NvOlz";
  String clientSecret =
      "hRSIOvDEqUS73b8MRGIqJLmfHD99D4k_qURIGi5pzG_q-K9KVWdFLl2VIAWAFIjm";
  String audience = "https://dev-lp6q46q3k22p2rez.us.auth0.com/api/v2/";

  try {
    Response response = await dio.post(
      "https://dev-lp6q46q3k22p2rez.us.auth0.com/oauth/token",
      data: {
        "client_id": clientId,
        "client_secret": clientSecret,
        "audience": audience,
        "grant_type": "client_credentials",
      },
      options: Options(
        headers: {'content-type': 'application/json'},
      ),
    );

    print(response.data);
  } catch (e) {
    print("Error: $e");
  }
}

Future<Response<dynamic>> performAuthorizedRequest() async {
  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String? accessToken = await secureStorage.read(key: 'accessToken');

  Dio dio = Dio();
  dio.interceptors.clear();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (isTokenExpired(accessToken!)) {
          print("Token expired, renewing...");
          try {
            await renewAuth();
            String? newAccessToken =
                await secureStorage.read(key: 'accessToken');
            options.headers['authorization'] = 'Bearer $newAccessToken';
          } catch (error) {
            print("Failed to renew token: $error");
            throw error;
          }
        } else {
          options.headers['authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
  );

  try {
    Response<dynamic> response = await dio.get("https://$DOMAIN/userinfo");
    print(response.data);
    return response;
  } catch (error) {
    print('Error: $error');
    throw error;
  }
}
