import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:type_mate/type_mate.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TypeMate Integration Tests', () {
    late TypeMate typeMate;

    setUpAll(() {
      typeMate = TypeMate.instance;
    });

    tearDownAll(() {
      typeMate.dispose();
    });

    group('Plugin Initialization', () {
      testWidgets('should initialize successfully', (
        WidgetTester tester,
      ) async {
        final result = await typeMate.initialize();
        expect(
          result,
          isTrue,
          reason: 'TypeMate should initialize successfully',
        );
      });

      testWidgets('should handle multiple initialization calls', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();
        final secondResult = await typeMate.initialize();
        expect(
          secondResult,
          isTrue,
          reason: 'Multiple initialization calls should succeed',
        );
      });
    });

    group('Permission Checking', () {
      testWidgets('should check overlay permission without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // This shouldn't throw an exception, regardless of permission state
        final hasPermission = await typeMate.checkOverlayPermission();
        expect(
          hasPermission,
          isA<bool>(),
          reason: 'Should return a boolean value',
        );
      });

      testWidgets('should check accessibility service without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // This shouldn't throw an exception, regardless of service state
        final isEnabled = await typeMate.checkAccessibilityService();
        expect(isEnabled, isA<bool>(), reason: 'Should return a boolean value');
      });

      testWidgets('should check all permissions without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        final hasAllPermissions = await typeMate.hasAllPermissions();
        expect(
          hasAllPermissions,
          isA<bool>(),
          reason: 'Should return a boolean value',
        );
      });
    });

    group('Permission Requests', () {
      testWidgets('should request overlay permission without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // This should not throw an exception
        // Note: In a real test environment, this might not actually open settings
        await expectLater(
          () async => await typeMate.requestOverlayPermission(),
          returnsNormally,
          reason: 'Permission request should complete without errors',
        );
      });

      testWidgets('should open accessibility settings without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // This should not throw an exception
        // Note: In a real test environment, this might not actually open settings
        await expectLater(
          () async => await typeMate.openAccessibilitySettings(),
          returnsNormally,
          reason:
              'Opening accessibility settings should complete without errors',
        );
      });
    });

    group('Service Management', () {
      testWidgets('should start overlay service without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // This should not throw an exception
        // Note: Service might not actually start without proper permissions
        await expectLater(
          () async => await typeMate.startOverlayService(),
          returnsNormally,
          reason: 'Starting overlay service should complete without errors',
        );
      });

      testWidgets('should stop overlay service without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // This should not throw an exception
        await expectLater(
          () async => await typeMate.stopOverlayService(),
          returnsNormally,
          reason: 'Stopping overlay service should complete without errors',
        );
      });

      testWidgets('should test overlay without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // This should not throw an exception
        await expectLater(
          () async => await typeMate.testOverlay(),
          returnsNormally,
          reason: 'Testing overlay should complete without errors',
        );
      });

      testWidgets('should check overlay visibility without errors', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        final isVisible = await typeMate.isOverlayVisible();
        expect(isVisible, isA<bool>(), reason: 'Should return a boolean value');
      });
    });

    group('Event Streams', () {
      testWidgets('should provide working text field focused stream', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        final stream = typeMate.textFieldFocusedStream;
        expect(
          stream,
          isA<Stream<void>>(),
          reason: 'Should provide a valid stream',
        );

        // Test that we can listen to the stream without errors
        final subscription = stream.listen((_) {
          // Event received
        });

        await tester.pumpAndSettle();
        await subscription.cancel();
      });

      testWidgets('should provide working text field unfocused stream', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        final stream = typeMate.textFieldUnfocusedStream;
        expect(
          stream,
          isA<Stream<void>>(),
          reason: 'Should provide a valid stream',
        );

        // Test that we can listen to the stream without errors
        final subscription = stream.listen((_) {
          // Event received
        });

        await tester.pumpAndSettle();
        await subscription.cancel();
      });

      testWidgets('should support multiple stream listeners', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        final stream = typeMate.textFieldFocusedStream;

        // Create multiple subscriptions
        final subscription1 = stream.listen((_) {});
        final subscription2 = stream.listen((_) {});

        await tester.pumpAndSettle();

        // Should not throw errors
        await subscription1.cancel();
        await subscription2.cancel();
      });
    });

    group('Quick Setup', () {
      testWidgets('should perform quick setup without errors', (
        WidgetTester tester,
      ) async {
        final result = await typeMate.quickSetup();

        expect(
          result,
          isA<Map<String, bool>>(),
          reason: 'Should return a status map',
        );
        expect(
          result.containsKey('initialized'),
          isTrue,
          reason: 'Should contain initialized status',
        );
        expect(
          result.containsKey('hasOverlayPermission'),
          isTrue,
          reason: 'Should contain overlay permission status',
        );
        expect(
          result.containsKey('hasAccessibilityService'),
          isTrue,
          reason: 'Should contain accessibility service status',
        );
        expect(
          result.containsKey('serviceStarted'),
          isTrue,
          reason: 'Should contain service started status',
        );
      });
    });

    group('Status Monitoring', () {
      testWidgets('should get comprehensive status', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        final status = await typeMate.getStatus();

        expect(
          status,
          isA<Map<String, dynamic>>(),
          reason: 'Should return a status map',
        );
        expect(
          status.containsKey('initialized'),
          isTrue,
          reason: 'Should contain initialized status',
        );
        expect(
          status.containsKey('hasOverlayPermission'),
          isTrue,
          reason: 'Should contain overlay permission status',
        );
        expect(
          status.containsKey('hasAccessibilityService'),
          isTrue,
          reason: 'Should contain accessibility service status',
        );
        expect(
          status.containsKey('isOverlayVisible'),
          isTrue,
          reason: 'Should contain overlay visibility status',
        );

        // All status values should be booleans
        expect(status['initialized'], isA<bool>());
        expect(status['hasOverlayPermission'], isA<bool>());
        expect(status['hasAccessibilityService'], isA<bool>());
        expect(status['isOverlayVisible'], isA<bool>());
      });
    });

    group('Error Handling', () {
      testWidgets('should handle platform channel errors gracefully', (
        WidgetTester tester,
      ) async {
        // Test what happens when the platform channel is not available
        // This simulates scenarios where the native implementation is not working

        await typeMate.initialize();

        // These calls should not crash the app, even if they fail internally
        final overlayPermission = await typeMate.checkOverlayPermission();
        final accessibilityService = await typeMate.checkAccessibilityService();

        expect(overlayPermission, isA<bool>());
        expect(accessibilityService, isA<bool>());
      });

      testWidgets('should handle method channel exceptions', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // Test that method calls don't throw unhandled exceptions
        // Even if the underlying platform implementation fails

        await expectLater(
          () async {
            await typeMate.startOverlayService();
            await typeMate.stopOverlayService();
            await typeMate.testOverlay();
            await typeMate.requestOverlayPermission();
            await typeMate.openAccessibilitySettings();
          },
          returnsNormally,
          reason: 'All method calls should handle errors gracefully',
        );
      });
    });

    group('Cleanup and Disposal', () {
      testWidgets('should dispose cleanly', (WidgetTester tester) async {
        final localTypeMate = TypeMate.instance;
        await localTypeMate.initialize();

        // Subscribe to streams
        final subscription1 = localTypeMate.textFieldFocusedStream.listen(
          (_) {},
        );
        final subscription2 = localTypeMate.textFieldUnfocusedStream.listen(
          (_) {},
        );

        await tester.pumpAndSettle();

        // Cancel subscriptions
        await subscription1.cancel();
        await subscription2.cancel();

        // Dispose should not throw
        expect(() => localTypeMate.dispose(), returnsNormally);
      });
    });

    group('Platform Specific Tests', () {
      testWidgets('should work correctly on Android', (
        WidgetTester tester,
      ) async {
        // These tests are specifically for Android functionality
        await typeMate.initialize();

        // Android-specific operations should work
        final overlayPermission = await typeMate.checkOverlayPermission();
        final accessibilityService = await typeMate.checkAccessibilityService();

        expect(overlayPermission, isA<bool>());
        expect(accessibilityService, isA<bool>());

        // Service operations should complete
        await typeMate.startOverlayService();
        await typeMate.testOverlay();
        await typeMate.stopOverlayService();
      });
    });

    group('Performance Tests', () {
      testWidgets('should handle rapid method calls', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        // Test rapid successive calls
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          futures.add(typeMate.checkOverlayPermission());
          futures.add(typeMate.checkAccessibilityService());
        }

        // All calls should complete successfully
        final results = await Future.wait(futures);
        expect(results.length, equals(20));

        for (final result in results) {
          expect(result, isA<bool>());
        }
      });

      testWidgets('should handle multiple stream subscriptions efficiently', (
        WidgetTester tester,
      ) async {
        await typeMate.initialize();

        final subscriptions = <StreamSubscription>[];

        // Create multiple subscriptions
        for (int i = 0; i < 10; i++) {
          subscriptions.add(typeMate.textFieldFocusedStream.listen((_) {}));
          subscriptions.add(typeMate.textFieldUnfocusedStream.listen((_) {}));
        }

        await tester.pumpAndSettle();

        // Clean up all subscriptions
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }

        expect(subscriptions.length, equals(20));
      });
    });
  });
}
