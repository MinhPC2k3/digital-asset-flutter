import 'package:flutter/services.dart';

class GoBridge {
  static const _channel = MethodChannel(
    'com.example.digital_asset_flutter/mpcclient',
  );

  static Future<String> computeShareKey(String sessionId, String accountKey, Uint8List clientSecret) async {
    final result = await _channel.invokeMethod<String>('computeShareKey', {
      'sessionId': sessionId,
      'accountKey': accountKey,
      'clientSecret': clientSecret
    });
    return result ?? '';
  }
}
