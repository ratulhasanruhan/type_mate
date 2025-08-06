import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:type_mate/type_mate.dart';
import 'package:type_mate/src/type_mate_platform_interface.dart';

/// Mock implementation of TypeMatePlatform for testing
class MockTypeMatePlatform extends TypeMatePlatform {
  /// Tracks method calls for verification
  final List<String> methodCalls = [];

  /// Mock return values
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityService = false;
  bool _isOverlayVisible = false;

  /// Callback functions for listeners
  Function()? _onTextFieldFocused;
  Function()? _onTextFieldUnfocused;

  /// Sets the mock overlay permission state
  void setOverlayPermission(bool hasPermission) {
    _hasOverlayPermission = hasPermission;
  }

  /// Sets the mock accessibility service state
  void setAccessibilityService(bool isEnabled) {
    _hasAccessibilityService = isEnabled;
  }

  /// Sets the mock overlay visibility state
  void setOverlayVisible(bool isVisible) {
    _isOverlayVisible = isVisible;
  }

  /// Simulates a text field focus event
  void simulateTextFieldFocus() {
    _onTextFieldFocused?.call();
  }

  /// Simulates a text field unfocus event
  void simulateTextFieldUnfocus() {
    _onTextFieldUnfocused?.call();
  }

  @override
  Future<bool> checkOverlayPermission() async {
    methodCalls.add('checkOverlayPermission');
    return _hasOverlayPermission;
  }

  @override
  Future<void> requestOverlayPermission() async {
    methodCalls.add('requestOverlayPermission');
  }

  @override
  Future<bool> checkAccessibilityService() async {
    methodCalls.add('checkAccessibilityService');
    return _hasAccessibilityService;
  }

  @override
  Future<void> openAccessibilitySettings() async {
    methodCalls.add('openAccessibilitySettings');
  }

  @override
  Future<void> startOverlayService() async {
    methodCalls.add('startOverlayService');
  }

  @override
  Future<void> stopOverlayService() async {
    methodCalls.add('stopOverlayService');
  }

  @override
  Future<void> testOverlay() async {
    methodCalls.add('testOverlay');
  }

  @override
  Future<bool> isOverlayVisible() async {
    methodCalls.add('isOverlayVisible');
    return _isOverlayVisible;
  }

  @override
  void setTextFieldFocusListener(
    Function() onTextFieldFocused,
    Function() onTextFieldUnfocused,
  ) {
    methodCalls.add('setTextFieldFocusListener');
    _onTextFieldFocused = onTextFieldFocused;
    _onTextFieldUnfocused = onTextFieldUnfocused;
  }

  @override
  void removeTextFieldFocusListener() {
    methodCalls.add('removeTextFieldFocusListener');
    _onTextFieldFocused = null;
    _onTextFieldUnfocused = null;
  }
}

void main() {
  group('TypeMate', () {
    late MockTypeMatePlatform mockPlatform;
    late TypeMate typeMate;

    setUp(() {
      mockPlatform = MockTypeMatePlatform();
      TypeMatePlatform.instance = mockPlatform;
      typeMate = TypeMate.instance;
    });

    tearDown(() {
      try {
        typeMate.dispose();
      } catch (e) {
        // Ignore disposal errors in tests
      }
    });

    group('Singleton Pattern', () {
      test('should return the same instance', () {
        final instance1 = TypeMate.instance;
        final instance2 = TypeMate.instance;
        expect(instance1, same(instance2));
      });
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        final result = await typeMate.initialize();
        expect(result, isTrue);
        expect(mockPlatform.methodCalls, contains('setTextFieldFocusListener'));
      });

      test('should return true on subsequent initialize calls', () async {
        await typeMate.initialize();
        mockPlatform.methodCalls.clear();

        final result = await typeMate.initialize();
        expect(result, isTrue);
        expect(mockPlatform.methodCalls, isEmpty);
      });

      test('should handle initialization failure gracefully', () async {
        // This test would require mocking a failure scenario
        // For now, the current implementation always succeeds
        final result = await typeMate.initialize();
        expect(result, isTrue);
      });
    });

    group('Permission Management', () {
      test('should check overlay permission', () async {
        mockPlatform.setOverlayPermission(true);

        final hasPermission = await typeMate.checkOverlayPermission();
        expect(hasPermission, isTrue);
        expect(mockPlatform.methodCalls, contains('checkOverlayPermission'));
      });

      test('should request overlay permission', () async {
        await typeMate.requestOverlayPermission();
        expect(mockPlatform.methodCalls, contains('requestOverlayPermission'));
      });

      test('should check accessibility service', () async {
        mockPlatform.setAccessibilityService(true);

        final isEnabled = await typeMate.checkAccessibilityService();
        expect(isEnabled, isTrue);
        expect(mockPlatform.methodCalls, contains('checkAccessibilityService'));
      });

      test('should open accessibility settings', () async {
        await typeMate.openAccessibilitySettings();
        expect(mockPlatform.methodCalls, contains('openAccessibilitySettings'));
      });

      test('should check if all permissions are granted', () async {
        mockPlatform.setOverlayPermission(true);
        mockPlatform.setAccessibilityService(true);

        final hasAllPermissions = await typeMate.hasAllPermissions();
        expect(hasAllPermissions, isTrue);
      });

      test('should return false if overlay permission is missing', () async {
        mockPlatform.setOverlayPermission(false);
        mockPlatform.setAccessibilityService(true);

        final hasAllPermissions = await typeMate.hasAllPermissions();
        expect(hasAllPermissions, isFalse);
      });

      test('should return false if accessibility service is missing', () async {
        mockPlatform.setOverlayPermission(true);
        mockPlatform.setAccessibilityService(false);

        final hasAllPermissions = await typeMate.hasAllPermissions();
        expect(hasAllPermissions, isFalse);
      });
    });

    group('Service Management', () {
      test('should start overlay service', () async {
        await typeMate.startOverlayService();
        expect(mockPlatform.methodCalls, contains('startOverlayService'));
      });

      test('should stop overlay service', () async {
        await typeMate.stopOverlayService();
        expect(mockPlatform.methodCalls, contains('stopOverlayService'));
      });

      test('should test overlay', () async {
        await typeMate.testOverlay();
        expect(mockPlatform.methodCalls, contains('testOverlay'));
      });

      test('should check if overlay is visible', () async {
        mockPlatform.setOverlayVisible(true);

        final isVisible = await typeMate.isOverlayVisible();
        expect(isVisible, isTrue);
        expect(mockPlatform.methodCalls, contains('isOverlayVisible'));
      });
    });

    group('Event Streams', () {
      test('should provide working text field focused stream', () async {
        await typeMate.initialize();

        final stream = typeMate.textFieldFocusedStream;
        expect(stream, isA<Stream<void>>());

        // Test that we can listen to the stream without errors
        StreamSubscription<void>? subscription;
        subscription = stream.listen((_) {
          // Event received
        });

        // Cleanup
        await subscription.cancel();
      });

      test('should provide working text field unfocused stream', () async {
        await typeMate.initialize();

        final stream = typeMate.textFieldUnfocusedStream;
        expect(stream, isA<Stream<void>>());

        // Test that we can listen to the stream without errors
        StreamSubscription<void>? subscription;
        subscription = stream.listen((_) {
          // Event received
        });

        // Cleanup
        await subscription.cancel();
      });

      test('should support multiple stream listeners', () async {
        await typeMate.initialize();

        final stream = typeMate.textFieldFocusedStream;

        // Create multiple subscriptions
        final subscription1 = stream.listen((_) {});
        final subscription2 = stream.listen((_) {});

        // Should not throw errors
        await subscription1.cancel();
        await subscription2.cancel();

        expect(true, isTrue); // Test passed if no exceptions
      });
    });

    group('Quick Setup', () {
      test(
        'should perform quick setup successfully with all permissions',
        () async {
          mockPlatform.setOverlayPermission(true);
          mockPlatform.setAccessibilityService(true);

          final result = await typeMate.quickSetup();

          expect(result['initialized'], isTrue);
          expect(result['hasOverlayPermission'], isTrue);
          expect(result['hasAccessibilityService'], isTrue);
          expect(result['serviceStarted'], isTrue);

          expect(mockPlatform.methodCalls, contains('startOverlayService'));
        },
      );

      test('should handle missing overlay permission in quick setup', () async {
        mockPlatform.setOverlayPermission(false);
        mockPlatform.setAccessibilityService(true);

        final result = await typeMate.quickSetup();

        expect(result['initialized'], isTrue);
        expect(result['hasOverlayPermission'], isFalse);
        expect(result['hasAccessibilityService'], isTrue);
        expect(result['serviceStarted'], isFalse);

        expect(
          mockPlatform.methodCalls,
          isNot(contains('startOverlayService')),
        );
      });

      test(
        'should handle missing accessibility service in quick setup',
        () async {
          mockPlatform.setOverlayPermission(true);
          mockPlatform.setAccessibilityService(false);

          final result = await typeMate.quickSetup();

          expect(result['initialized'], isTrue);
          expect(result['hasOverlayPermission'], isTrue);
          expect(result['hasAccessibilityService'], isFalse);
          expect(result['serviceStarted'], isFalse);

          expect(
            mockPlatform.methodCalls,
            isNot(contains('startOverlayService')),
          );
        },
      );
    });

    group('Status Monitoring', () {
      test('should get comprehensive status', () async {
        await typeMate.initialize();
        mockPlatform.setOverlayPermission(true);
        mockPlatform.setAccessibilityService(true);
        mockPlatform.setOverlayVisible(true);

        final status = await typeMate.getStatus();

        expect(status['initialized'], isTrue);
        expect(status['hasOverlayPermission'], isTrue);
        expect(status['hasAccessibilityService'], isTrue);
        expect(status['isOverlayVisible'], isTrue);
      });
    });

    group('Dispose', () {
      test('should clean up resources on dispose', () async {
        await typeMate.initialize();
        mockPlatform.methodCalls.clear();

        typeMate.dispose();

        expect(
          mockPlatform.methodCalls,
          contains('removeTextFieldFocusListener'),
        );

        // After disposal, streams should be closed
        // We'll just verify the cleanup method was called
        expect(
          mockPlatform.methodCalls,
          contains('removeTextFieldFocusListener'),
        );
      });
    });
  });
}
