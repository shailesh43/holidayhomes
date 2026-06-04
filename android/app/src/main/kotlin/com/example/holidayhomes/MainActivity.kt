package com.tatapower.holidayhomes

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.security.cert.X509Certificate

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.tatapower.holidayhomes/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUserInstalledCACerts" ->
                        result.success(hasUserInstalledCACerts())
                    else ->
                        result.notImplemented()
                }
            }
    }

    private fun hasUserInstalledCACerts(): Boolean {
        return try {
            val tmf = javax.net.ssl.TrustManagerFactory.getInstance(
                javax.net.ssl.TrustManagerFactory.getDefaultAlgorithm()
            )
            // Load the AndroidCAStore which merges system + user certs
            val ks = KeyStore.getInstance("AndroidCAStore").apply { load(null) }
            tmf.init(ks)

            ks.aliases().asSequence().any { alias ->
                // User-installed certs have aliases prefixed with "user:"
                alias.startsWith("user:")
            }
        } catch (e: Exception) {
            false // Don't block if check fails — avoids false positives
        }
    }
}