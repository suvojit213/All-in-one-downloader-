package com.example.all_in_one_downloader

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import kotlinx.coroutines.*
import java.io.File
import java.io.FileOutputStream
import java.net.URL

class DownloadService : Service() {
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val CHANNEL_ID = "download_channel"
    private val NOTIFICATION_ID = 1001

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val url = intent?.getStringExtra("url")
        val fileName = intent?.getStringExtra("fileName")
        val downloadPath = intent?.getStringExtra("downloadPath")

        if (url != null && fileName != null && downloadPath != null) {
            startForeground(NOTIFICATION_ID, createNotification("Starting download...", 0))
            downloadFile(url, fileName, downloadPath)
        }

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Download Notifications",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows download progress"
                setSound(null, null)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(contentText: String, progress: Int): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("All in One Downloader")
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setProgress(100, progress, progress == 0)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    private fun downloadFile(url: String, fileName: String, downloadPath: String) {
        serviceScope.launch {
            try {
                val file = File(downloadPath, fileName)
                val connection = URL(url).openConnection()
                val fileSize = connection.contentLength
                
                connection.getInputStream().use { input ->
                    FileOutputStream(file).use { output ->
                        val buffer = ByteArray(8192)
                        var totalBytesRead = 0
                        var bytesRead: Int

                        while (input.read(buffer).also { bytesRead = it } != -1) {
                            output.write(buffer, 0, bytesRead)
                            totalBytesRead += bytesRead

                            if (fileSize > 0) {
                                val progress = (totalBytesRead * 100 / fileSize)
                                updateNotification("Downloading... $progress%", progress)
                            }
                        }
                    }
                }

                // Download completed
                updateNotification("Download completed", 100)
                
                // Stop the service after a delay
                delay(2000)
                stopSelf()

            } catch (e: Exception) {
                updateNotification("Download failed: ${e.message}", -1)
                delay(3000)
                stopSelf()
            }
        }
    }

    private fun updateNotification(text: String, progress: Int) {
        val notification = createNotification(text, progress)
        val notificationManager = NotificationManagerCompat.from(this)
        
        try {
            notificationManager.notify(NOTIFICATION_ID, notification)
        } catch (e: SecurityException) {
            // Handle notification permission not granted
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
    }
}

