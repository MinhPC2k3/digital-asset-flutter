import 'package:flutter/services.dart';

class GoBridge {
  static const _channel = MethodChannel('com.example.digital_asset_flutter/mpcclient');

  static Future<String> computeShareKey(
    String sessionId,
    String accountKey,
    Uint8List clientSecret,
  ) async {
    final result = await _channel.invokeMethod<String>('computeShareKey', {
      'sessionId': sessionId,
      'accountKey': accountKey,
      'clientSecret': clientSecret,
    });
    return result ?? '';
  }

  static Future<String> prepareSign(String sessionId, Uint8List rawMsg) async {
    final result = await _channel.invokeMethod<String>('prepareSign', {
      'sessionId': sessionId,
      'rawMsg': rawMsg,
    });
    return result ?? '';
  }

  static Future<String> invokeSign(
    String sessionId,
    Uint8List round1Sum,
    Uint8List clientSecret,
  ) async {
    final result = await _channel.invokeMethod<String>('invokeSign', {
      'sessionId': sessionId,
      'round1Sum': round1Sum,
      'clientSecret': clientSecret,
    });
    return result ?? '';
  }

  static Future<String> combineSignature(
      String sessionId,
      Uint8List round2Sum,
      Uint8List rx,
      ) async {
    final result = await _channel.invokeMethod<String>('combineSignature', {
      'sessionId': sessionId,
      'round2Sum': round2Sum,
      'rx': rx,
    });
    return result ?? '';
  }

  static Future<String> getFingerprint(
      String chainIdStr,
      String nonceStr,
      String toStr,
      String valueStr,
      String gasStr,
      String gasPriceStr,
      String inputStr,
      ) async {
    final result = await _channel.invokeMethod<String>('getFingerprint', {
      'chainIdStr': chainIdStr,
      'nonceStr': nonceStr,
      'toStr': toStr,
      'valueStr': valueStr,
      'gasStr': gasStr,
      'gasPriceStr': gasPriceStr,
      'inputStr': inputStr,
    });
    return result ?? '';
  }
}
