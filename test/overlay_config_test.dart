import 'package:flutter_test/flutter_test.dart';
import 'package:type_mate/src/models/overlay_config.dart';

void main() {
  group('OverlayConfig', () {
    group('Constructor', () {
      test('should create config with default values', () {
        const config = OverlayConfig();

        expect(config.autoShow, isTrue);
        expect(config.autoHideDuration, equals(3000));
        expect(config.enableVibration, isFalse);
        expect(config.bubbleColor, isNull);
        expect(config.bubbleSize, equals(56.0));
        expect(config.bubbleOpacity, equals(0.9));
        expect(config.enableSpellCheck, isTrue);
        expect(config.enableGrammarCheck, isTrue);
        expect(config.initialX, equals(100));
        expect(config.initialY, equals(200));
      });

      test('should create config with custom values', () {
        const config = OverlayConfig(
          autoShow: false,
          autoHideDuration: 5000,
          enableVibration: true,
          bubbleColor: '#FF5722',
          bubbleSize: 64.0,
          bubbleOpacity: 0.8,
          enableSpellCheck: false,
          enableGrammarCheck: false,
          initialX: 150,
          initialY: 250,
        );

        expect(config.autoShow, isFalse);
        expect(config.autoHideDuration, equals(5000));
        expect(config.enableVibration, isTrue);
        expect(config.bubbleColor, equals('#FF5722'));
        expect(config.bubbleSize, equals(64.0));
        expect(config.bubbleOpacity, equals(0.8));
        expect(config.enableSpellCheck, isFalse);
        expect(config.enableGrammarCheck, isFalse);
        expect(config.initialX, equals(150));
        expect(config.initialY, equals(250));
      });
    });

    group('copyWith', () {
      test('should create copy with modified values', () {
        const originalConfig = OverlayConfig();

        final newConfig = originalConfig.copyWith(
          autoShow: false,
          bubbleSize: 64.0,
          bubbleColor: '#FF5722',
        );

        expect(newConfig.autoShow, isFalse);
        expect(newConfig.bubbleSize, equals(64.0));
        expect(newConfig.bubbleColor, equals('#FF5722'));

        // Unchanged values should remain the same
        expect(
          newConfig.autoHideDuration,
          equals(originalConfig.autoHideDuration),
        );
        expect(
          newConfig.enableVibration,
          equals(originalConfig.enableVibration),
        );
        expect(newConfig.bubbleOpacity, equals(originalConfig.bubbleOpacity));
        expect(
          newConfig.enableSpellCheck,
          equals(originalConfig.enableSpellCheck),
        );
        expect(
          newConfig.enableGrammarCheck,
          equals(originalConfig.enableGrammarCheck),
        );
        expect(newConfig.initialX, equals(originalConfig.initialX));
        expect(newConfig.initialY, equals(originalConfig.initialY));
      });

      test(
        'should create copy with all values unchanged when no parameters provided',
        () {
          const originalConfig = OverlayConfig(
            autoShow: false,
            autoHideDuration: 5000,
            enableVibration: true,
            bubbleColor: '#FF5722',
            bubbleSize: 64.0,
            bubbleOpacity: 0.8,
            enableSpellCheck: false,
            enableGrammarCheck: false,
            initialX: 150,
            initialY: 250,
          );

          final newConfig = originalConfig.copyWith();

          expect(newConfig.autoShow, equals(originalConfig.autoShow));
          expect(
            newConfig.autoHideDuration,
            equals(originalConfig.autoHideDuration),
          );
          expect(
            newConfig.enableVibration,
            equals(originalConfig.enableVibration),
          );
          expect(newConfig.bubbleColor, equals(originalConfig.bubbleColor));
          expect(newConfig.bubbleSize, equals(originalConfig.bubbleSize));
          expect(newConfig.bubbleOpacity, equals(originalConfig.bubbleOpacity));
          expect(
            newConfig.enableSpellCheck,
            equals(originalConfig.enableSpellCheck),
          );
          expect(
            newConfig.enableGrammarCheck,
            equals(originalConfig.enableGrammarCheck),
          );
          expect(newConfig.initialX, equals(originalConfig.initialX));
          expect(newConfig.initialY, equals(originalConfig.initialY));
        },
      );
    });

    group('Serialization', () {
      test('should convert to map correctly', () {
        const config = OverlayConfig(
          autoShow: false,
          autoHideDuration: 5000,
          enableVibration: true,
          bubbleColor: '#FF5722',
          bubbleSize: 64.0,
          bubbleOpacity: 0.8,
          enableSpellCheck: false,
          enableGrammarCheck: false,
          initialX: 150,
          initialY: 250,
        );

        final map = config.toMap();

        expect(map['autoShow'], isFalse);
        expect(map['autoHideDuration'], equals(5000));
        expect(map['enableVibration'], isTrue);
        expect(map['bubbleColor'], equals('#FF5722'));
        expect(map['bubbleSize'], equals(64.0));
        expect(map['bubbleOpacity'], equals(0.8));
        expect(map['enableSpellCheck'], isFalse);
        expect(map['enableGrammarCheck'], isFalse);
        expect(map['initialX'], equals(150));
        expect(map['initialY'], equals(250));
      });

      test('should create from map correctly', () {
        final map = {
          'autoShow': false,
          'autoHideDuration': 5000,
          'enableVibration': true,
          'bubbleColor': '#FF5722',
          'bubbleSize': 64.0,
          'bubbleOpacity': 0.8,
          'enableSpellCheck': false,
          'enableGrammarCheck': false,
          'initialX': 150,
          'initialY': 250,
        };

        final config = OverlayConfig.fromMap(map);

        expect(config.autoShow, isFalse);
        expect(config.autoHideDuration, equals(5000));
        expect(config.enableVibration, isTrue);
        expect(config.bubbleColor, equals('#FF5722'));
        expect(config.bubbleSize, equals(64.0));
        expect(config.bubbleOpacity, equals(0.8));
        expect(config.enableSpellCheck, isFalse);
        expect(config.enableGrammarCheck, isFalse);
        expect(config.initialX, equals(150));
        expect(config.initialY, equals(250));
      });

      test('should handle missing values in map with defaults', () {
        final map = <String, dynamic>{'autoShow': false, 'bubbleSize': 64.0};

        final config = OverlayConfig.fromMap(map);

        expect(config.autoShow, isFalse);
        expect(config.bubbleSize, equals(64.0));

        // Should use defaults for missing values
        expect(config.autoHideDuration, equals(3000));
        expect(config.enableVibration, isFalse);
        expect(config.bubbleColor, isNull);
        expect(config.bubbleOpacity, equals(0.9));
        expect(config.enableSpellCheck, isTrue);
        expect(config.enableGrammarCheck, isTrue);
        expect(config.initialX, equals(100));
        expect(config.initialY, equals(200));
      });

      test('should handle empty map with all defaults', () {
        final config = OverlayConfig.fromMap(<String, dynamic>{});

        expect(config.autoShow, isTrue);
        expect(config.autoHideDuration, equals(3000));
        expect(config.enableVibration, isFalse);
        expect(config.bubbleColor, isNull);
        expect(config.bubbleSize, equals(56.0));
        expect(config.bubbleOpacity, equals(0.9));
        expect(config.enableSpellCheck, isTrue);
        expect(config.enableGrammarCheck, isTrue);
        expect(config.initialX, equals(100));
        expect(config.initialY, equals(200));
      });

      test('should handle type conversion for numeric values', () {
        final map = {
          'bubbleSize': 64, // int instead of double
          'bubbleOpacity': 1, // int instead of double
        };

        final config = OverlayConfig.fromMap(map);

        expect(config.bubbleSize, equals(64.0));
        expect(config.bubbleOpacity, equals(1.0));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        const config1 = OverlayConfig(
          autoShow: false,
          autoHideDuration: 5000,
          enableVibration: true,
          bubbleColor: '#FF5722',
          bubbleSize: 64.0,
          bubbleOpacity: 0.8,
          enableSpellCheck: false,
          enableGrammarCheck: false,
          initialX: 150,
          initialY: 250,
        );

        const config2 = OverlayConfig(
          autoShow: false,
          autoHideDuration: 5000,
          enableVibration: true,
          bubbleColor: '#FF5722',
          bubbleSize: 64.0,
          bubbleOpacity: 0.8,
          enableSpellCheck: false,
          enableGrammarCheck: false,
          initialX: 150,
          initialY: 250,
        );

        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('should not be equal when properties differ', () {
        const config1 = OverlayConfig();
        const config2 = OverlayConfig(autoShow: false);

        expect(config1, isNot(equals(config2)));
        expect(config1.hashCode, isNot(equals(config2.hashCode)));
      });

      test('should be equal to itself', () {
        const config = OverlayConfig();
        expect(config, equals(config));
      });
    });

    group('toString', () {
      test('should provide readable string representation', () {
        const config = OverlayConfig(
          autoShow: false,
          bubbleSize: 64.0,
          bubbleColor: '#FF5722',
        );

        final stringRepresentation = config.toString();

        expect(stringRepresentation, contains('OverlayConfig'));
        expect(stringRepresentation, contains('autoShow: false'));
        expect(stringRepresentation, contains('bubbleSize: 64.0'));
        expect(stringRepresentation, contains('bubbleColor: #FF5722'));
      });
    });

    group('Validation', () {
      test('should accept valid bubble size values', () {
        const config1 = OverlayConfig(bubbleSize: 32.0);
        const config2 = OverlayConfig(bubbleSize: 128.0);

        expect(config1.bubbleSize, equals(32.0));
        expect(config2.bubbleSize, equals(128.0));
      });

      test('should accept valid opacity values', () {
        const config1 = OverlayConfig(bubbleOpacity: 0.0);
        const config2 = OverlayConfig(bubbleOpacity: 1.0);
        const config3 = OverlayConfig(bubbleOpacity: 0.5);

        expect(config1.bubbleOpacity, equals(0.0));
        expect(config2.bubbleOpacity, equals(1.0));
        expect(config3.bubbleOpacity, equals(0.5));
      });

      test('should accept valid auto hide duration values', () {
        const config1 = OverlayConfig(autoHideDuration: 0);
        const config2 = OverlayConfig(autoHideDuration: 10000);

        expect(config1.autoHideDuration, equals(0));
        expect(config2.autoHideDuration, equals(10000));
      });

      test('should accept valid position values', () {
        const config = OverlayConfig(initialX: -100, initialY: -50);

        expect(config.initialX, equals(-100));
        expect(config.initialY, equals(-50));
      });
    });

    group('Round-trip Serialization', () {
      test(
        'should maintain data integrity through serialization round-trip',
        () {
          const originalConfig = OverlayConfig(
            autoShow: false,
            autoHideDuration: 5000,
            enableVibration: true,
            bubbleColor: '#FF5722',
            bubbleSize: 64.0,
            bubbleOpacity: 0.8,
            enableSpellCheck: false,
            enableGrammarCheck: false,
            initialX: 150,
            initialY: 250,
          );

          final map = originalConfig.toMap();
          final deserializedConfig = OverlayConfig.fromMap(map);

          expect(deserializedConfig, equals(originalConfig));
        },
      );
    });
  });
}
