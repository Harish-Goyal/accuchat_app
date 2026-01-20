
import 'dart:convert';

extension EncodingExtensions on String {
  /// To Base64
  String get toBase64 {
    return base64.encode(toUtf8);
  }
  /// To Utf8
  List<int> get toUtf8 {
    return utf8.encode(this);
  }
  // To Sha256
  // String get toSha256 {
  //   return sha256.convert(toUtf8).toString();
  // }
}
