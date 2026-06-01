package com.hsr.isertoolkit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val PROPS_CHANNEL = "com.hsr.isertoolkit/props"
    private val DAEMON_CHANNEL = "com.hsr.isertoolkit/daemon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PROPS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getprop" -> {
                        val key = call.argument<String>("key") ?: ""
                        val default_ = call.argument<String>("default") ?: ""
                        result.success(SystemPropsHelper.get(key, default_))
                    }
                    "setprop" -> {
                        val key = call.argument<String>("key") ?: ""
                        val value = call.argument<String>("value") ?: ""
                        result.success(SystemPropsHelper.set(key, value))
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DAEMON_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendCommand" -> {
                        val cmd = call.argument<String>("command") ?: ""
                        val value = call.argument<String>("value") ?: ""
                        Thread {
                            val resp = DaemonBridge.send("$cmd:$value")
                            activity.runOnUiThread { result.success(resp) }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }
    }
}