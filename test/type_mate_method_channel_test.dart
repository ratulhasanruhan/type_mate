import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:type_mate/src/type_mate_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelTypeMate', () {
    const MethodChannel channel = MethodChannel('type_mate');
    MethodChannelTypeMate platform = MethodChannelTypeMate();
    late List<MethodCall> log;

    setUp(() {
      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            switch (methodCall.method) {
              case 'checkOverlayPermission':
                return true;
              case 'requestOverlayPermission':
                return null;
              case 'checkAccessibilityService':
                return true;
              case 'openAccessibilitySettings':
                return null;
              case 'startOverlayService':
                return null;
              case 'stopOverlayService':
                return null;
              case 'testOverlay':
                return null;
              case 'isOverlayVisible':
                return false;
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    group('Permission Methods', () {
      test('checkOverlayPermission calls correct method', () async {
        final result = await platform.checkOverlayPermission();

        expect(result, isTrue);
        expect(log, <Matcher>[
          isMethodCall('checkOverlayPermission', arguments: null),
        ]);
      });

      test('requestOverlayPermission calls correct method', () async {
        await platform.requestOverlayPermission();

        expect(log, <Matcher>[
          isMethodCall('requestOverlayPermission', arguments: null),
        ]);
      });

      test('checkAccessibilityService calls correct method', () async {
        final result = await platform.checkAccessibilityService();

        expect(result, isTrue);
        expect(log, <Matcher>[
          isMethodCall('checkAccessibilityService', arguments: null),
        ]);
      });

      test('openAccessibilitySettings calls correct method', () async {
        await platform.openAccessibilitySettings();

        expect(log, <Matcher>[
          isMethodCall('openAccessibilitySettings', arguments: null),
        ]);
      });
    });

    group('Service Methods', () {
      test('startOverlayService calls correct method', () async {
        await platform.startOverlayService();

        expect(log, <Matcher>[
          isMethodCall('startOverlayService', arguments: null),
        ]);
      });

      test('stopOverlayService calls correct method', () async {
        await platform.stopOverlayService();

        expect(log, <Matcher>[
          isMethodCall('stopOverlayService', arguments: null),
        ]);
      });

      test('testOverlay calls correct method', () async {
        await platform.testOverlay();

        expect(log, <Matcher>[isMethodCall('testOverlay', arguments: null)]);
      });

      test('isOverlayVisible calls correct method', () async {
        final result = await platform.isOverlayVisible();

        expect(result, isFalse);
        expect(log, <Matcher>[
          isMethodCall('isOverlayVisible', arguments: null),
        ]);
      });
    });

    group('Error Handling', () {
      test('handles PlatformException for checkOverlayPermission', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              throw PlatformException(
                code: 'PERMISSION_ERROR',
                message: 'Failed to check permission',
              );
            });

        final result = await platform.checkOverlayPermission();
        expect(result, isFalse); // Should return false on error
      });

      test('handles PlatformException for checkAccessibilityService', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              throw PlatformException(
                code: 'SERVICE_ERROR',
                message: 'Failed to check service',
              );
            });

        final result = await platform.checkAccessibilityService();
        expect(result, isFalse); // Should return false on error
      });

      test(
        'handles PlatformException for service methods gracefully',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                throw PlatformException(
                  code: 'SERVICE_ERROR',
                  message: 'Failed to start service',
                );
              });

          // These should not throw exceptions
          await expectLater(
            () async => await platform.startOverlayService(),
            returnsNormally,
          );

          await expectLater(
            () async => await platform.stopOverlayService(),
            returnsNormally,
          );

          await expectLater(
            () async => await platform.testOverlay(),
            returnsNormally,
          );

          await expectLater(
            () async => await platform.requestOverlayPermission(),
            returnsNormally,
          );

          await expectLater(
            () async => await platform.openAccessibilitySettings(),
            returnsNormally,
          );
        },
      );

      test('handles null return values gracefully', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              channel,
              (MethodCall methodCall) async => null,
            );

        // Boolean methods should return false for null
        expect(await platform.checkOverlayPermission(), isFalse);
        expect(await platform.checkAccessibilityService(), isFalse);
        expect(await platform.isOverlayVisible(), isFalse);
      });
    });

    group('Text Field Focus Listeners', () {
      test('setTextFieldFocusListener sets callbacks', () async {
        bool focusedCalled = false;
        bool unfocusedCalled = false;

        platform.setTextFieldFocusListener(
          () => focusedCalled = true,
          () => unfocusedCalled = true,
        );

        // Simulate method calls from platform using channel
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              channel.name,
              channel.codec.encodeMethodCall(
                const MethodCall('onTextFieldFocused'),
              ),
              (data) {},
            );

        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              channel.name,
              channel.codec.encodeMethodCall(
                const MethodCall('onTextFieldUnfocused'),
              ),
              (data) {},
            );

        // Wait for async operations to complete
        await Future.delayed(const Duration(milliseconds: 10));

        expect(focusedCalled, isTrue);
        expect(unfocusedCalled, isTrue);
      });

      test('removeTextFieldFocusListener clears callbacks', () async {
        bool focusedCalled = false;
        bool unfocusedCalled = false;

        platform.setTextFieldFocusListener(
          () => focusedCalled = true,
          () => unfocusedCalled = true,
        );

        platform.removeTextFieldFocusListener();

        // Simulate method calls from platform after removal
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              channel.name,
              channel.codec.encodeMethodCall(
                const MethodCall('onTextFieldFocused'),
              ),
              (data) {},
            );

        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              channel.name,
              channel.codec.encodeMethodCall(
                const MethodCall('onTextFieldUnfocused'),
              ),
              (data) {},
            );

        // Wait for async operations to complete
        await Future.delayed(const Duration(milliseconds: 10));

        expect(focusedCalled, isFalse);
        expect(unfocusedCalled, isFalse);
      });

      test('handles callback methods without throwing', () async {
        // Should not throw even without callbacks set
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              channel.name,
              channel.codec.encodeMethodCall(
                const MethodCall('onTextFieldFocused'),
              ),
              (data) {},
            );

        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              channel.name,
              channel.codec.encodeMethodCall(
                const MethodCall('onTextFieldUnfocused'),
              ),
              (data) {},
            );

        // If we get here without exceptions, the test passes
        expect(true, isTrue);
      });
    });

    group('Method Channel Configuration', () {
      test('uses correct channel name', () {
        expect(platform.methodChannel.name, equals('type_mate'));
      });

      test('method channel is visible for testing', () {
        expect(platform.methodChannel, isA<MethodChannel>());
      });
    });

    group('Async Operation Handling', () {
      test('handles concurrent method calls', () async {
        // Test multiple concurrent calls
        final futures = <Future>[
          platform.checkOverlayPermission(),
          platform.checkAccessibilityService(),
          platform.isOverlayVisible(),
        ];

        final results = await Future.wait(futures);

        expect(results, hasLength(3));
        expect(results[0], isA<bool>());
        expect(results[1], isA<bool>());
        expect(results[2], isA<bool>());
      });

      test('handles rapid successive calls', () async {
        final results = <bool>[];

        for (int i = 0; i < 5; i++) {
          results.add(await platform.checkOverlayPermission());
        }

        expect(results, hasLength(5));
        expect(results.every((result) => result == true), isTrue);
      });
    });
  });
}
