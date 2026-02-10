import 'dart:io';
import 'package:AccuChat/Components/custom_loader.dart';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:AccuChat/Services/error_res.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../Constants/strings.dart';
import '../main.dart';

class NetworkExceptions {
  static String messageData = "";

  static getDioException(error) {
    if (error is Exception) {
      try {
        if (error is DioError) {
          if (error.type == DioExceptionType.badResponse) {
            switch (error.response!.statusCode) {
              case 400:
              return ErrorResponseModel.fromJson(error.response?.data).message;
              case 401:
                logoutLocal();
                Get.offAllNamed(AppRoutes.login_r);
                customLoader.hide();
                return ErrorResponseModel.fromJson(error.response?.data).message;
              case 403:
                logoutLocal();
                Get.offAllNamed(AppRoutes.login_r);
                customLoader.hide();
                return ErrorResponseModel.fromJson(error.response?.data)
                    .message;
              case 404:
                logoutLocal();
                Get.offAllNamed(AppRoutes.login_r);
                customLoader.hide();
                return messageData = STRING_notFound;
              case 408:
                return messageData = STRING_requestTimeOut;
              case 500:
                return messageData = STRING_internalServerError;
              case 503:
                return messageData = STRING_internetServiceUnavail;
              default:
                return ErrorResponseModel.fromJson(error.response?.data)
                    .message;
            // return messageData = STRING_somethingsIsWrong;
            }
          } else if (error.type == DioExceptionType.unknown) {
            return ErrorResponseModel.fromJson(
                error.response?.data["phone_number"].val("phone_number"));
          } else if (error.type == DioExceptionType.cancel) {
            return messageData = STRING_requestCancelled;
          } else if (error.type == DioExceptionType.connectionError) {
            return messageData = STRING_internetConnection;
          } else if (error.type == DioExceptionType.connectionTimeout) {
            return messageData = STRING_connectionTimeout;
          } else if (error.type == DioExceptionType.receiveTimeout) {
            return messageData = STRING_timeOut;
          } else if (error.type == DioExceptionType.sendTimeout) {
            return messageData = STRING_connectionRefused;
          } else if (error is SocketException) {
            return messageData = socketExceptions;
          } else {
            return messageData = STRING_unexpectedException;
          }
        }
      } on FormatException catch (_) {
        return messageData = STRING_formatException;
      } catch (_) {
        return messageData = STRING_unexpectedException;
      }
    } else {
      if (error.toString().contains(STRING_notsubType)) {
        return messageData = STRING_unableToProcessData;
      } else {
        return messageData = STRING_unexpectedException;
      }
    }
  }
}
