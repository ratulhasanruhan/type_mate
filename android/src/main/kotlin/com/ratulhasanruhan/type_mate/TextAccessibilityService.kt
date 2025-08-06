package com.ratulhasanruhan.type_mate

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class TextAccessibilityService : AccessibilityService() {
    private var isBubbleVisible = false
    private var isInTextField = false
    private var hideHandler: android.os.Handler? = null
    private var hideRunnable: Runnable? = null
    private val HIDE_DELAY = 3000L // 3 seconds delay before hiding

    companion object {
        private const val TAG = "TypeMateAccessibility"
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        
        hideHandler = android.os.Handler(android.os.Looper.getMainLooper())
        
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            notificationTimeout = 50
        }
        
        setServiceInfo(info)
        Log.d(TAG, "TypeMate Accessibility Service Connected!")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let { 
            Log.d(TAG, "Event received: ${event.eventType}, Class: ${event.className}")
            
            when (it.eventType) {
                AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED -> {
                    Log.d(TAG, "Text change event detected")
                    if (isTextField(event)) {
                        Log.d(TAG, "User is typing - showing bubble with delay")
                        showBubbleWithDelay()
                    }
                }
            }
        }
    }

    private fun showBubbleWithDelay() {
        try {
            // Show bubble immediately
            val intent = Intent(this, OverlayService::class.java)
            intent.putExtra("action", "show_bubble")
            startService(intent)
            Log.d(TAG, "Bubble shown")
            
            // Simple delayed hide without complex timer logic
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                Log.d(TAG, "Hiding bubble after delay")
                hideBubble()
            }, HIDE_DELAY)
        } catch (e: Exception) {
            Log.e(TAG, "Error in showBubbleWithDelay: ${e.message}")
        }
    }

    private fun showBubble() {
        val intent = Intent(this, OverlayService::class.java)
        intent.putExtra("action", "show_bubble")
        startService(intent)
        Log.d(TAG, "Bubble shown")
    }

    private fun hideBubble() {
        val intent = Intent(this, OverlayService::class.java)
        intent.putExtra("action", "hide_bubble")
        startService(intent)
        Log.d(TAG, "Bubble hidden")
    }

    override fun onInterrupt() {
        Log.d(TAG, "TypeMate Accessibility Service Interrupted")
    }

    private fun getFieldIdentifier(event: AccessibilityEvent): String {
        val source = event.source
        return if (source != null) {
            "${source.className}_${source.viewIdResourceName}_${source.windowId}"
        } else {
            "${event.className}_${event.windowId}"
        }
    }

    private fun isTextField(event: AccessibilityEvent): Boolean {
        val className = event.className?.toString() ?: ""
        val isEditable = event.source?.isEditable ?: false
        val contentDescription = event.contentDescription?.toString() ?: ""
        val text = event.text?.toString() ?: ""
        
        val isEditText = className.contains("EditText")
        val isTextView = className.contains("TextView") && isEditable
        val isInputField = className.contains("Input") || className.contains("Field")
        val isTextInput = className.contains("TextInput")
        val isWebView = className.contains("WebView") && isEditable
        val isAutoCompleteTextView = className.contains("AutoCompleteTextView")
        val isMultiAutoCompleteTextView = className.contains("MultiAutoCompleteTextView")
        val isSearchView = className.contains("SearchView")
        val isSearchAutoComplete = className.contains("SearchAutoComplete")
        
        // Additional checks for common input patterns
        val hasInputHint = contentDescription.contains("input") || contentDescription.contains("text")
        val hasTextContent = text.isNotEmpty() && text.length < 1000 // Reasonable text length
        
        val result = isEditText || isTextView || isInputField || isTextInput || isWebView || 
                    isAutoCompleteTextView || isMultiAutoCompleteTextView || isSearchView || 
                    isSearchAutoComplete || isEditable || hasInputHint || hasTextContent
        
        Log.d(TAG, "isTextField check: $result, Class: $className, Editable: $isEditable, ContentDesc: $contentDescription")
        return result
    }
}