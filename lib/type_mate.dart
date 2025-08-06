/// TypeMate Plugin Library
///
/// A Flutter plugin for system-wide writing assistance with overlay bubbles
/// that provide spell checking, grammar fixing, and other writing tools.
///
/// ## Features
///
/// - System-wide text input tracking using Android Accessibility Service
/// - Overlay bubble functionality with customizable appearance
/// - Permission management for overlay and accessibility services
/// - Real-time text field focus detection across all applications
/// - Stream-based event system for notifications
///
/// ## Platform Support
///
/// - ✅ Android (API 21+)
/// - ❌ iOS (not supported due to platform limitations)
///
/// ## Usage
///
/// ```dart
/// import 'package:type_mate/type_mate.dart';
///
/// // Initialize the plugin
/// await TypeMate.instance.initialize();
///
/// // Quick setup with permissions and service start
/// final result = await TypeMate.instance.quickSetup();
///
/// // Listen to text field events
/// TypeMate.instance.textFieldFocusedStream.listen((_) {
///   print('Text field focused!');
/// });
/// ```
///
/// See [TypeMate] for the main plugin class and [OverlayConfig] for
/// configuration options.
library type_mate;

export 'src/type_mate_platform_interface.dart';
export 'src/type_mate_method_channel.dart';
export 'src/type_mate.dart';
export 'src/models/overlay_config.dart';
