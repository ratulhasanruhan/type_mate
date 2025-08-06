import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'type_mate_platform_interface.dart';

/// An implementation of [TypeMatePlatform] that uses method channels.
class MethodChannelTypeMate extends TypeMatePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('type_mate');

  /// Text field focus listeners
  static Function()? _onTextFieldFocused;
  static Function()? _onTextFieldUnfocused;

  MethodChannelTypeMate() {
    // Set up method call handler for callbacks from native side
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextFieldFocused':
        debugPrint('Text field focused in external app');
        _onTextFieldFocused?.call();
        break;
      case 'onTextFieldUnfocused':
        debugPrint('Text field unfocused in external app');
        _onTextFieldUnfocused?.call();
        break;
    }
  }

  @override
  Future<bool> checkOverlayPermission() async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'checkOverlayPermission',
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking overlay permission: $e');
      return false;
    }
  }

  @override
  Future<void> requestOverlayPermission() async {
    try {
      await methodChannel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      debugPrint('Error requesting overlay permission: $e');
    }
  }

  @override
  Future<void> startOverlayService() async {
    try {
      await methodChannel.invokeMethod('startOverlayService');
    } catch (e) {
      debugPrint('Error starting overlay service: $e');
    }
  }

  @override
  Future<void> stopOverlayService() async {
    try {
      await methodChannel.invokeMethod('stopOverlayService');
    } catch (e) {
      debugPrint('Error stopping overlay service: $e');
    }
  }

  @override
  Future<void> testOverlay() async {
    try {
      await methodChannel.invokeMethod('testOverlay');
    } catch (e) {
      debugPrint('Error testing overlay: $e');
    }
  }

  @override
  Future<bool> isOverlayVisible() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isOverlayVisible');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking overlay visibility: $e');
      return false;
    }
  }

  @override
  Future<bool> checkAccessibilityService() async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'checkAccessibilityService',
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking accessibility service: $e');
      return false;
    }
  }

  @override
  Future<void> openAccessibilitySettings() async {
    try {
      await methodChannel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('Error opening accessibility settings: $e');
    }
  }

  @override
  void setTextFieldFocusListener(
    Function() onTextFieldFocused,
    Function() onTextFieldUnfocused,
  ) {
    _onTextFieldFocused = onTextFieldFocused;
    _onTextFieldUnfocused = onTextFieldUnfocused;
  }

  @override
  void removeTextFieldFocusListener() {
    _onTextFieldFocused = null;
    _onTextFieldUnfocused = null;
  }
}
