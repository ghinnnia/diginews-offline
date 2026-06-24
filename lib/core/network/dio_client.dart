import 'package:dio/dio.dart';

class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Tambahkan API Key atau log global di sini
    options.queryParameters['apiKey'] = 'YOUR_NEWS_API_KEY';
    print("Executing Request to: ${options.path}");
    super.onRequest(options, handler);
  }
}

class DioClient {
  final Dio dio;
  DioClient(this.dio) {
    dio.options.baseUrl = "https://newsapi.org/v2/";
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.interceptors.add(CustomInterceptor());
  }
}