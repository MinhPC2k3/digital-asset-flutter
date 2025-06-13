package com.example.digital_asset_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import gomobile.Gomobile

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.digital_asset_flutter/mpcclient"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "computeShareKey" -> {
                    val sessionId = call.argument<String>("sessionId") ?: ""
                    val accountKey = call.argument<String>("accountKey") ?: ""
                    val clientSecret = call.argument<ByteArray>("clientSecret")
                    val mpcClient = Gomobile.newMPCMobileClient()
                    val message = mpcClient.computeShareKey(
                        sessionId,
                        accountKey,
                        clientSecret
                    ) // gọi đúng instance
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
