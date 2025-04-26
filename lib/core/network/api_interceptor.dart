import 'package:dio/dio.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/storage/local_storage.dart';

class ApiInterceptor extends Interceptor {
  final Dio dio;

  ApiInterceptor(this.dio);

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    return handler.next(options);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    print("I am in onError");
    print("path : ${err.requestOptions.path}");
    const List<String> authPaths = ['/ms-auth/api/auth/login', '/ms-auth/api/auth/register', '/ms-auth/api/auth/refresh-token'];

    if (err.response?.statusCode == 401 && !authPaths.contains(err.requestOptions.path)) {
      print("onError: 401 Unauthorized");

      final refreshed = await _refreshToken();

      if (refreshed) {
        print("Retrying request after token refresh");
        final newAccessToken = await LocalStorage.instance.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        return handler.resolve(await dio.fetch(err.requestOptions)); // Retry request
      } else {
        print("Refresh failed, clearing tokens");
        await _clearTokens(); // Clear tokens and log out the user
        return handler.reject(DioException(requestOptions: err.requestOptions, response: Response(statusCode: 401, requestOptions: err.requestOptions, statusMessage: "Unauthorized")));
      }
    }

    return handler.next(err); // Forward error if not 401 or refresh fails
  }

  Future<bool> _refreshToken() async {
    print("Refreshing token");
    final refreshToken = await LocalStorage.instance.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      print("No refresh token found");
      return false;
    }

    try {
      final apiClient = ApiClient();
      final response = await apiClient.post('/ms-auth/api/auth/refresh-token', {'refreshToken': refreshToken});

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['accessToken'];
        print("New access token");
        await LocalStorage.instance.setAccessToken(newAccessToken);
        return true;
      }
    } catch (e) {
      e as ApiException;
      print('Refresh token failed: ${e.message}');
      return false;
    }

    return false;
  }

  Future<void> _clearTokens() async {
    await LocalStorage.instance.setAccessToken("");
    await LocalStorage.instance.setRefreshToken("");
    print("Tokens cleared, user should be logged out.");
  }
}
