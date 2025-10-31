import 'dart:io';
export 'dart:async';
export 'dart:convert';
export 'dart:typed_data';
import 'package:AccuChat/Services/APIs/log_intercepters.dart' as LogInterceptor;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../storage_service.dart';

const _defaultConnectTimeout = Duration.millisecondsPerMinute;
const _defaultReceiveTimeout = Duration.millisecondsPerMinute;

setContentType() {
  return "application/json";
}

class DioClient {
  String baseUrl;

  static late Dio _dio;

  final List<Interceptor>? interceptors;

  DioClient(
    this.baseUrl,
    Dio dio, {
    this.interceptors,
  }) {
    _dio = dio;
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = _defaultConnectTimeout.milliseconds
      ..options.receiveTimeout = _defaultReceiveTimeout.milliseconds
      ..httpClientAdapter
      ..options.contentType = setContentType()
      ..options.headers = {
        'Content-Type': setContentType(),
      };

    if (interceptors?.isNotEmpty ?? false) {
      _dio.interceptors.addAll(interceptors!);
    }
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor.LogInterceptor(
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: false,
          request: false,
          requestBody: true));
    }
   /* if(kIsWeb){
      HttpClient client = HttpClient();
      client.badCertificateCallback =((X509Certificate cert, String  host, int port) => true);

       (_dio.httpClientAdapter as DefaultHttpClientAdapter).createHttpClient!()
        .badCertificateCallback = ((X509Certificate cert, String host, int port) {
          final isValidHost = ["192.168.1.21"].contains(host); // <-- allow only hosts in array
          // final isValidHost = ["192.168.1.67"].contains(host); // <-- allow only hosts in array
          return isValidHost;
        });
   }*/
    if (!kIsWeb) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    /*(_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient dioClient ) {
      dioClient.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
      return dioClient;
    };*/
  }

  Future<dynamic> get(String uri,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress,
      bool? skipAuth}) async {
    try {
      if (skipAuth == false) {
        var token = StorageService.getToken();
        debugPrint("Authorization token is ******* $token");
        if (token != null) {
          options = Options(headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          });
        }
      }
      var response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw e;
    }
  }

// fpdart
  Future<dynamic> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? skipAuth,
  }) async {
    try {
      if (skipAuth == false) {
        var token =  StorageService.getToken();
        debugPrint("authorization token is ********* $token");

        if (token != null) {
          if (options == null) {
            options = Options(headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json"
            });
          }
        }
      }

      /*if (options == null) {
        options = Options(headers: {"Content-Type": "application/json"});
      }*/
      var response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw FormatException("Unable to process the data");
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> put(String uri,
      {data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      bool? skipAuth}) async {
    try {
      if (skipAuth == false) {
        var token =  StorageService.getToken();
        debugPrint("Authorization token is *********  $token");

        if (token != null) {
          options ??= Options(headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          });
        }
      }
      var response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> delete(String uri,
      {data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      bool? skipAuth}) async {
    try {
      if (skipAuth == false) {
        var token =  StorageService.getToken();
        debugPrint("Authorization token is *********  $token");

        if (token != null) {
          options ??= Options(headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          });
        }
      }
      var response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw e;
    }
  }
}
