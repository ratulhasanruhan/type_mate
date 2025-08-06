import 'dart:async';

import 'package:type_mate/src/type_mate_platform_interface.dart';

/// The main TypeMate plugin class that provides system-wide text input tracking
/// and overlay functionality.
///
/// This plugin enables tracking user text input across all applications
/// and displays a popup overlay bubble when typing is detected.
///
/// ## Overview
///
/// TypeMate works by combining two Android services:
/// - **Accessibility Service**: Detects text field focus events system-wide
/// - **Overlay Service**: Displays floating bubbles over other applications
///
/// ## Usage Example
///
/// ```dart
/// // Initialize the plugin
/// final typeMate = TypeMate.instance;
/// await typeMate.initialize();
///
/// // Set up event listeners
/// typeMate.textFieldFocusedStream.listen((_) {
///   print('User started typing!');
/// });
///
/// // Check and request permissions
/// if (!await typeMate.hasAllPermissions()) {
///   await typeMate.requestOverlayPermission();
///   await typeMate.openAccessibilitySettings();
/// }
///
/// // Start the overlay service
/// await typeMate.startOverlayService();
/// ```
///
/// ## Permissions Required
///
/// - **SYSTEM_ALERT_WINDOW**: For displaying overlay bubbles
/// - **BIND_ACCESSIBILITY_SERVICE**: For detecting text input events
/// - **FOREGROUND_SERVICE**: For running the overlay service
///
/// ## Platform Support
///
/// Currently only supports Android API 21+. iOS is not supported due to
/// platform limitations that prevent system-wide overlays.
///
/// See also:
/// - [OverlayConfig] for configuration options
/// - [TypeMatePlatform] for the platform interface
class TypeMate {
  /// Private constructor to prevent instantiation.
  ///
  /// Use [TypeMate.instance] to access the singleton instance.
  TypeMate._();

  /// Singleton instance of TypeMate.
  ///
  /// This ensures only one instance of TypeMate exists throughout the
  /// application lifecycle, preventing conflicts and resource issues.
  static final TypeMate _instance = TypeMate._();

  /// Gets the singleton instance of TypeMate.
  ///
  /// Returns the same instance across all calls, ensuring consistent
  /// state management and event handling.
  ///
  /// Example:
  /// ```dart
  /// final typeMate = TypeMate.instance;
  /// await typeMate.initialize();
  /// ```
  static TypeMate get instance => _instance;

  /// Stream controller for text field focused events.
  ///
  /// Uses broadcast streams to allow multiple listeners.
  final StreamController<void> _textFieldFocusedController =
      StreamController<void>.broadcast();

  /// Stream controller for text field unfocused events.
  ///
  /// Uses broadcast streams to allow multiple listeners.
  final StreamController<void> _textFieldUnfocusedController =
      StreamController<void>.broadcast();

  /// Stream of text field focused events.
  ///
  /// Emits an event whenever a text field gains focus in any application
  /// on the device. This requires the accessibility service to be enabled.
  ///
  /// The stream is a broadcast stream, allowing multiple listeners.
  ///
  /// Example:
  /// ```dart
  /// TypeMate.instance.textFieldFocusedStream.listen((_) {
  ///   print('User started typing in a text field!');
  ///   // Show additional UI, start spell checking, etc.
  /// });
  /// ```
  ///
  /// Note: This only works when the accessibility service is enabled
  /// and the overlay service is running.
  Stream<void> get textFieldFocusedStream => _textFieldFocusedController.stream;

  /// Stream of text field unfocused events.
  ///
  /// Emits an event whenever a text field loses focus in any application
  /// on the device. This requires the accessibility service to be enabled.
  ///
  /// The stream is a broadcast stream, allowing multiple listeners.
  ///
  /// Example:
  /// ```dart
  /// TypeMate.instance.textFieldUnfocusedStream.listen((_) {
  ///   print('User stopped typing in a text field!');
  ///   // Hide UI, save state, etc.
  /// });
  /// ```
  ///
  /// Note: This only works when the accessibility service is enabled
  /// and the overlay service is running.
  Stream<void> get textFieldUnfocusedStream =>
      _textFieldUnfocusedController.stream;

  /// Whether the service is currently initialized.
  ///
  /// This flag tracks if [initialize] has been called successfully.
  bool _isInitialized = false;

  /// Initializes the TypeMate plugin.
  ///
  /// This method must be called before using any other functionality.
  /// It sets up the communication bridge with the native platform and
  /// prepares the event listeners for text field focus events.
  ///
  /// Returns `true` if initialization was successful, `false` otherwise.
  /// Multiple calls to this method are safe - subsequent calls will
  /// return `true` immediately if already initialized.
  ///
  /// Example:
  /// ```dart
  /// final typeMate = TypeMate.instance;
  /// if (await typeMate.initialize()) {
  ///   print('TypeMate initialized successfully!');
  ///   // Continue with setup...
  /// } else {
  ///   print('Failed to initialize TypeMate');
  /// }
  /// ```
  ///
  /// Note: Initialization only sets up the Dart-side components.
  /// You still need to handle permissions and start services separately.
  ///
  /// See also:
  /// - [quickSetup] for a one-step initialization with permissions
  /// - [checkOverlayPermission] and [checkAccessibilityService] for permission checks
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Set up the text field focus listeners
      TypeMatePlatform.instance.setTextFieldFocusListener(
        () => _textFieldFocusedController.add(null),
        () => _textFieldUnfocusedController.add(null),
      );

      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose the plugin and clean up resources
  void dispose() {
    TypeMatePlatform.instance.removeTextFieldFocusListener();
    _textFieldFocusedController.close();
    _textFieldUnfocusedController.close();
    _isInitialized = false;
  }

  /// Check if overlay permission is granted
  ///
  /// This permission is required to display overlay bubbles on top of other apps.
  /// Returns true if permission is granted.
  Future<bool> checkOverlayPermission() async {
    return await TypeMatePlatform.instance.checkOverlayPermission();
  }

  /// Request system overlay permission
  ///
  /// This will open the system settings where the user can grant overlay permission.
  Future<void> requestOverlayPermission() async {
    return await TypeMatePlatform.instance.requestOverlayPermission();
  }

  /// Check if accessibility service is enabled
  ///
  /// This service is required to track text field focus events across all apps.
  /// Returns true if the service is enabled.
  Future<bool> checkAccessibilityService() async {
    return await TypeMatePlatform.instance.checkAccessibilityService();
  }

  /// Open accessibility settings
  ///
  /// This will open the system accessibility settings where the user can
  /// enable the TypeMate accessibility service.
  Future<void> openAccessibilitySettings() async {
    return await TypeMatePlatform.instance.openAccessibilitySettings();
  }

  /// Check if all required permissions are granted
  Future<bool> hasAllPermissions() async {
    final overlayPermission = await checkOverlayPermission();
    final accessibilityService = await checkAccessibilityService();
    return overlayPermission && accessibilityService;
  }

  /// Start the overlay service
  ///
  /// The overlay service will track text input across all apps and
  /// display a popup bubble when typing is detected.
  ///
  /// Make sure to check permissions first using [hasAllPermissions].
  Future<void> startOverlayService() async {
    return await TypeMatePlatform.instance.startOverlayService();
  }

  /// Stop the overlay service
  ///
  /// This will stop tracking text input and remove any visible overlay bubbles.
  Future<void> stopOverlayService() async {
    return await TypeMatePlatform.instance.stopOverlayService();
  }

  /// Test the overlay functionality
  ///
  /// This will show a test bubble for a few seconds to verify that
  /// the overlay is working correctly.
  Future<void> testOverlay() async {
    return await TypeMatePlatform.instance.testOverlay();
  }

  /// Check if the overlay is currently visible
  Future<bool> isOverlayVisible() async {
    return await TypeMatePlatform.instance.isOverlayVisible();
  }

  /// Quick setup method for common use cases
  ///
  /// This method will:
  /// 1. Initialize the plugin
  /// 2. Check if permissions are granted
  /// 3. Start the overlay service if permissions are available
  ///
  /// Returns a map with the setup status:
  /// - 'initialized': bool - whether initialization was successful
  /// - 'hasOverlayPermission': bool - whether overlay permission is granted
  /// - 'hasAccessibilityService': bool - whether accessibility service is enabled
  /// - 'serviceStarted': bool - whether the overlay service was started
  Future<Map<String, bool>> quickSetup() async {
    final result = <String, bool>{};

    // Initialize
    result['initialized'] = await initialize();
    if (!result['initialized']!) {
      return result;
    }

    // Check permissions
    result['hasOverlayPermission'] = await checkOverlayPermission();
    result['hasAccessibilityService'] = await checkAccessibilityService();

    // Start service if permissions are available
    if (result['hasOverlayPermission']! && result['hasAccessibilityService']!) {
      try {
        await startOverlayService();
        result['serviceStarted'] = true;
      } catch (e) {
        result['serviceStarted'] = false;
      }
    } else {
      result['serviceStarted'] = false;
    }

    return result;
  }

  /// Get status of all components
  ///
  /// Returns a comprehensive status of the plugin including:
  /// - Initialization status
  /// - Permission status
  /// - Service status
  Future<Map<String, dynamic>> getStatus() async {
    return {
      'initialized': _isInitialized,
      'hasOverlayPermission': await checkOverlayPermission(),
      'hasAccessibilityService': await checkAccessibilityService(),
      'isOverlayVisible': await isOverlayVisible(),
    };
  }
}
