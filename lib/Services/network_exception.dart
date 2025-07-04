import 'dart:io';
import 'package:AccuChat/Services/error_res.dart';
import 'package:dio/dio.dart';

import '../Constants/strings.dart';

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
               // Map<String, dynamic> data = error.response?.data;
               //
               // if (data.values.elementAt(0).runtimeType == String) {
               //   return messageData = data.values.elementAt(0);
               // } else {
               //   Map<String, dynamic> datas = data.values.elementAt(0);
               //   if (data.values.elementAt(0) == null) {
               //     var dataValue = ErrorResponseModel.fromJson(
               //         error.response?.data)
               //         .message;
               //     if (dataValue == null) {
               //       return messageData = STRING_unauthRequest;
               //     } else {
               //       return messageData = dataValue;
               //     }
               //   }
               //   else {
               //     return messageData = datas.values.first[0];
               //   }
               // }
              case 401:
                return ErrorResponseModel.fromJson(error.response?.data).message;

              case 403:
                return ErrorResponseModel.fromJson(error.response?.data)
                    .message;
              case 404:
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
