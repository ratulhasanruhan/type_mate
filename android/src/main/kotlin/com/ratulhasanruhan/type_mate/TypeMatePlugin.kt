package com.ratulhasanruhan.type_mate

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** TypeMatePlugin */
class TypeMatePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var activityBinding: ActivityPluginBinding? = null

  companion object {
    private const val OVERLAY_PERMISSION_REQUEST_CODE = 1234
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "type_mate")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "checkOverlayPermission" -> {
        result.success(checkOverlayPermission())
      }
      "requestOverlayPermission" -> {
        requestOverlayPermission()
        result.success(null)
      }
      "startOverlayService" -> {
        startOverlayService()
        result.success(null)
      }
      "stopOverlayService" -> {
        stopOverlayService()
        result.success(null)
      }
      "testOverlay" -> {
        testOverlay()
        result.success(null)
      }
      "checkAccessibilityService" -> {
        val isEnabled = isAccessibilityServiceEnabled()
        result.success(isEnabled)
      }
      "openAccessibilitySettings" -> {
        openAccessibilitySettings()
        result.success(null)
      }
      "isOverlayVisible" -> {
        val isVisible = isOverlayVisible()
        result.success(isVisible)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun checkOverlayPermission(): Boolean {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      Settings.canDrawOverlays(context)
    } else {
      true
    }
  }

  private fun requestOverlayPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      if (!Settings.canDrawOverlays(context)) {
        val intent = Intent(
          Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
          Uri.parse("package:${context.packageName}")
        )
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        activityBinding?.activity?.startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST_CODE) ?: 
        context.startActivity(intent)
      }
    }
  }

  private fun startOverlayService() {
    val intent = Intent(context, OverlayService::class.java)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      context.startForegroundService(intent)
    } else {
      context.startService(intent)
    }
  }

  private fun stopOverlayService() {
    val intent = Intent(context, OverlayService::class.java)
    context.stopService(intent)
  }

  private fun testOverlay() {
    val intent = Intent(context, OverlayService::class.java)
    intent.putExtra("action", "show_bubble")
    context.startService(intent)
  }

  private fun isAccessibilityServiceEnabled(): Boolean {
    val enabledServices = Settings.Secure.getString(
      context.contentResolver, 
      Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
    ) ?: ""
    val serviceName = "${context.packageName}/.TextAccessibilityService"
    return enabledServices.contains(serviceName)
  }

  private fun openAccessibilitySettings() {
    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
    context.startActivity(intent)
  }

  private fun isOverlayVisible(): Boolean {
    // This would need to be implemented with a way to communicate with the service
    // For now, we'll return a default value
    return false
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activityBinding = binding
  }

  override fun onDetachedFromActivity() {
    activityBinding = null
  }
}