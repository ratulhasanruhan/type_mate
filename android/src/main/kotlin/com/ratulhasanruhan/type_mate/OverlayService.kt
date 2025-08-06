package com.ratulhasanruhan.type_mate

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat

class OverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isOverlayVisible = false

    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "type_mate_overlay_service"
        private const val TAG = "TypeMateOverlay"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "OverlayService onCreate()")
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "OverlayService onStartCommand() - action: ${intent?.getStringExtra("action")}")
        startForeground(NOTIFICATION_ID, createNotification())
        
        // Handle intent actions from accessibility service
        when (intent?.getStringExtra("action")) {
            "show_bubble" -> {
                Log.d(TAG, "Received show_bubble action")
                showOverlay()
            }
            "hide_bubble" -> {
                Log.d(TAG, "Received hide_bubble action")
                hideOverlay()
            }
            "toggle_bubble" -> {
                Log.d(TAG, "Received toggle_bubble action")
                if (isOverlayVisible) {
                    hideOverlay()
                } else {
                    showOverlay()
                }
            }
        }
        
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "TypeMate Overlay Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Service for showing TypeMate text input overlay"
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("TypeMate Active")
            .setContentText("Tap text fields in any app to get writing assistance")
            .setSmallIcon(android.R.drawable.ic_menu_edit)
            .setOngoing(true)
            .build()
    }

    private fun showOverlay() {
        Log.d(TAG, "showOverlay() called, isOverlayVisible: $isOverlayVisible")

        try {
            if (overlayView == null) {
                overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_bubble, null)
                Log.d(TAG, "Overlay view inflated successfully")
                
                val params = WindowManager.LayoutParams(
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                    } else {
                        WindowManager.LayoutParams.TYPE_PHONE
                    },
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                    PixelFormat.TRANSLUCENT
                ).apply {
                    gravity = Gravity.TOP or Gravity.START
                    x = 100
                    y = 200
                }

                windowManager?.addView(overlayView, params)
                isOverlayVisible = true
                Log.d(TAG, "Overlay added to window manager successfully")
                
                // Set up click listeners only when creating new overlay
                overlayView?.findViewById<View>(R.id.btn_check)?.setOnClickListener {
                    Log.d(TAG, "Check button clicked")
                    // TODO: Implement spell check functionality
                }

                overlayView?.findViewById<View>(R.id.btn_fix)?.setOnClickListener {
                    Log.d(TAG, "Fix button clicked")
                    // TODO: Implement grammar fix functionality
                }

                overlayView?.findViewById<View>(R.id.btn_close)?.setOnClickListener {
                    Log.d(TAG, "Close button clicked")
                    hideOverlay()
                }
            } else {
                Log.d(TAG, "Overlay already exists, keeping it stable")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error showing overlay: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun hideOverlay() {
        Log.d(TAG, "hideOverlay() called, isOverlayVisible: $isOverlayVisible")
        if (isOverlayVisible && overlayView != null) {
            try {
                windowManager?.removeView(overlayView)
                overlayView = null
                isOverlayVisible = false
                Log.d(TAG, "Overlay removed from window manager successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error hiding overlay: ${e.message}")
                e.printStackTrace()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "OverlayService onDestroy()")
        hideOverlay()
    }
}