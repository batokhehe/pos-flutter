import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://reqres.in/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'x-api-key': 'reqres-free-v1',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) {
          debugPrint(obj.toString());
        },
      ),
    );

  Future<Response> post(String path, Map<String, dynamic> data) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw Exception('POST Error: \${e.response?.data ?? e.message}');
    }
  }

  Future<Response> get(String path) async {
    try {
      return await dio.get(path);
    } on DioException catch (e) {
      throw Exception('GET Error: \${e.response?.data ?? e.message}');
    }
  }
}
