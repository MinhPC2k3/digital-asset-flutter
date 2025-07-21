package com.example.digital_asset_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import gomobile.Gomobile

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.digital_asset_flutter/mpcclient"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val mpcClient = Gomobile.newMPCMobileClient()
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "computeShareKey" -> {
                    val sessionId = call.argument<String>("sessionId") ?: ""
                    val accountKey = call.argument<String>("accountKey") ?: ""
                    val clientSecret = call.argument<ByteArray>("clientSecret")
                    val message = mpcClient.computeShareKey(
                        sessionId,
                        accountKey,
                        clientSecret
                    ) // gọi đúng instance
                    result.success(message)
                }

                "prepareSign" -> {
                    val sessionId = call.argument<String>("sessionId") ?: ""
                    val rawMsg = call.argument<ByteArray>("rawMsg")
                    val message = mpcClient.prepareSign(
                        sessionId,
                        rawMsg
                    )
                    result.success(message)
                }

                "invokeSign" -> {
                    val sessionId = call.argument<String>("sessionId") ?: ""
                    val round1Sum = call.argument<ByteArray>("round1Sum")
                    val clientSecret = call.argument<ByteArray>("clientSecret")
                    val message = mpcClient.invokeSign(
                        sessionId,
                        round1Sum,
                        clientSecret
                    )
                    result.success(message)
                }

                "combineSignature" -> {
                    val sessionId = call.argument<String>("sessionId") ?: ""
                    val round2Sum = call.argument<ByteArray>("round2Sum")
                    val rx = call.argument<ByteArray>("rx")
                    val message = mpcClient.combineSignature(
                        sessionId,
                        round2Sum,
                        rx
                    )
                    result.success(message)
                }

                "getFingerprint" -> {
                    val chainIdStr = call.argument<String>("chainIdStr") ?: ""
                    val nonceStr = call.argument<String>("nonceStr") ?: ""
                    val toStr = call.argument<String>("toStr") ?: ""
                    val gasStr = call.argument<String>("gasStr") ?: ""
                    val gasPriceStr = call.argument<String>("gasPriceStr") ?: ""
                    val inputStr = call.argument<String>("inputStr") ?: ""
                    val valueStr = call.argument<String>("valueStr") ?: ""
                    val message = mpcClient.getFingerPrint(
                        chainIdStr, nonceStr, toStr, valueStr, gasStr, gasPriceStr, inputStr
                    )
                    result.success(message)
                }

                else -> result.notImplemented()
            }
        }
    }
}

// Cầu nối tới hàm native trong thư viện .so
//class GoBridge {
//    external fun hello(name: String): String
//
//    companion object {
//        init {
//            System.loadLibrary("gojni")
//        }
//    }
//}
