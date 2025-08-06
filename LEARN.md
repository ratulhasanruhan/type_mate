# 📖 Learn TypeMate

Welcome to **TypeMate** learning guide!  
This document explains **how TypeMate works**, **how to set it up**, and **how to use it effectively**.

---

## 1️⃣ What is TypeMate?

TypeMate is a Flutter plugin that shows a **writing assistant overlay bubble** when a user focuses on any text field **across all Android apps**.

**Key Concepts:**
- **Accessibility Service** detects text field focus events.
- **Overlay Service** displays a bubble over other apps.
- **Flutter Plugin API** lets you control the overlay from your app.

---

## 2️⃣ How TypeMate Works (Architecture)

```
User taps a text field in any app
        ↓
Accessibility Service detects focus event
        ↓
Overlay Service displays bubble
        ↓
Flutter plugin communicates actions back to your app
```

---

## 3️⃣ Setup Guide

### **Step 1: Install the Plugin**
```yaml
dependencies:
  type_mate: ^1.0.0
```

---

### **Step 2: Configure Android Permissions**

Add these to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
```

---

### **Step 3: Register Services**
Inside `<application>` tag of `AndroidManifest.xml`:

```xml
<!-- Overlay Service -->
<service
    android:name="com.ratulhasanruhan.type_mate.OverlayService"
    android:enabled="true"
    android:exported="false"
    android:foregroundServiceType="mediaProjection" />

<!-- Accessibility Service -->
<service
    android:name="com.ratulhasanruhan.type_mate.TextAccessibilityService"
    android:enabled="true"
    android:exported="true"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibility_service_config" />
</service>
```

---

### **Step 4: Permissions on Device**
When running the app:
- **Overlay Permission** → User must grant “Draw over other apps”.
- **Accessibility Service** → User must enable TypeMate service in Accessibility settings.
- *(Optional)* Disable **Battery Optimization** for stable background service.

---

## 4️⃣ Basic Usage

```dart
import 'package:type_mate/type_mate.dart';

@override
void initState() {
  super.initState();
  setupTypeMate();
}

Future<void> setupTypeMate() async {
  // Initialize plugin
  await TypeMate.instance.initialize();

  // Quick setup (permissions + service start)
  final result = await TypeMate.instance.quickSetup();
  if (result['serviceStarted'] == true) {
    print('TypeMate is running!');
  }

  // Listen for text field focus events
  TypeMate.instance.textFieldFocusedStream.listen((_) {
    print('Text field focused');
  });
}
```

---

## 5️⃣ Advanced Usage

**Check permissions manually:**
```dart
bool overlay = await TypeMate.instance.checkOverlayPermission();
bool accessibility = await TypeMate.instance.checkAccessibilityService();
```

**Request permissions:**
```dart
if (!overlay) await TypeMate.instance.requestOverlayPermission();
if (!accessibility) await TypeMate.instance.openAccessibilitySettings();
```

**Control services:**
```dart
await TypeMate.instance.startOverlayService();
await TypeMate.instance.stopOverlayService();
await TypeMate.instance.testOverlay();
```

---

## 6️⃣ Debugging & Common Issues

| Issue | Possible Fix |
|-------|--------------|
| Bubble not showing | Ensure Overlay Permission is granted |
| Service stops after some time | Disable Battery Optimization |
| Accessibility events not firing | Toggle Accessibility Service OFF then ON |
| No reaction on text fields | Try on a native Android keyboard / form |

---

## 7️⃣ Best Practices
- Always **check permissions** before starting services.
- Use **`quickSetup()`** for easy integration.
- For advanced apps, handle **focus events** yourself to show custom UI.
- Keep the **bubble lightweight** to avoid distracting the user.

---

## 8️⃣ Next Steps
- Experiment with **custom bubbles** (planned feature in upcoming versions)
- Combine TypeMate with AI / NLP APIs for powerful writing assistants
- Contribute improvements via [GitHub](https://github.com/ratulhasanruhan/type_mate)

---

## 📌 Summary
TypeMate enables **system-wide writing assistance** in Flutter apps.  
With minimal setup, you can detect text fields anywhere on Android and display your own tools in real-time.

---
**🔗 Resources**
- [Pub.dev Package](https://pub.dev/packages/type_mate)  
- [GitHub Repository](https://github.com/ratulhasanruhan/type_mate)  

---

🚀 Happy coding with TypeMate!
