package com.example.all_in_one_downloader

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.all_in_one_downloader/native"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "showToast" -> {
                    val message = call.argument<String>("message") ?: "Default message"
                    showToast(message)
                    result.success(null)
                }
                "shareFile" -> {
                    val filePath = call.argument<String>("filePath")
                    val mimeType = call.argument<String>("mimeType") ?: "image/*"
                    if (filePath != null) {
                        shareFile(filePath, mimeType)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                    }
                }
                "openFile" -> {
                    val filePath = call.argument<String>("filePath")
                    val mimeType = call.argument<String>("mimeType") ?: "image/*"
                    if (filePath != null) {
                        val success = openFile(filePath, mimeType)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                    }
                }
                "getIntentData" -> {
                    val intentData = getIntentData()
                    result.success(intentData)
                }
                "clearIntentData" -> {
                    clearIntentData()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW) {
            val data = intent.data
            if (data != null && isInstagramUrl(data.toString())) {
                // Store the URL to be retrieved by Flutter
                sharedUrl = data.toString()
                
                // Notify Flutter if the method channel is available
                methodChannel?.invokeMethod("onUrlReceived", mapOf("url" to data.toString()))
            }
        }
    }

    private fun isInstagramUrl(url: String): Boolean {
        return url.contains("instagram.com") && 
               (url.contains("/p/") || url.contains("/reel/") || url.contains("/stories/"))
    }

    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    private fun shareFile(filePath: String, mimeType: String) {
        try {
            val file = java.io.File(filePath)
            if (file.exists()) {
                val uri = androidx.core.content.FileProvider.getUriForFile(
                    this,
                    "${packageName}.fileprovider",
                    file
                )
                
                val shareIntent = Intent().apply {
                    action = Intent.ACTION_SEND
                    type = mimeType
                    putExtra(Intent.EXTRA_STREAM, uri)
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                
                startActivity(Intent.createChooser(shareIntent, "Share via"))
            } else {
                showToast("File not found")
            }
        } catch (e: Exception) {
            showToast("Error sharing file: ${e.message}")
        }
    }

    private fun openFile(filePath: String, mimeType: String): Boolean {
        return try {
            val file = java.io.File(filePath)
            if (file.exists()) {
                val uri = androidx.core.content.FileProvider.getUriForFile(
                    this,
                    "${packageName}.fileprovider",
                    file
                )
                
                val openIntent = Intent().apply {
                    action = Intent.ACTION_VIEW
                    setDataAndType(uri, mimeType)
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                
                if (openIntent.resolveActivity(packageManager) != null) {
                    startActivity(openIntent)
                    true
                } else {
                    showToast("No app found to open this file")
                    false
                }
            } else {
                showToast("File not found")
                false
            }
        } catch (e: Exception) {
            showToast("Error opening file: ${e.message}")
            false
        }
    }

    private fun getIntentData(): String? {
        return sharedUrl
    }

    private fun clearIntentData() {
        sharedUrl = null
    }

    companion object {
        private var sharedUrl: String? = null
    }
}

