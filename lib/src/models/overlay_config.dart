/// Configuration class for the overlay bubble appearance and behavior.
///
/// This class provides comprehensive customization options for the TypeMate
/// overlay bubble that appears when users type in text fields.
///
/// ## Usage Example
///
/// ```dart
/// final config = OverlayConfig(
///   autoShow: true,
///   autoHideDuration: 5000, // 5 seconds
///   bubbleSize: 64.0,
///   bubbleOpacity: 0.9,
///   enableSpellCheck: true,
///   enableGrammarCheck: true,
///   enableVibration: false,
///   initialX: 100,
///   initialY: 200,
/// );
///
/// // Use with TypeMate
/// // await TypeMate.instance.startOverlayService(config); // Future feature
/// ```
///
/// ## Configuration Options
///
/// The configuration supports:
/// - **Appearance**: Size, opacity, color, and position
/// - **Behavior**: Auto-show, auto-hide, vibration feedback
/// - **Features**: Enable/disable spell check and grammar check
///
/// All properties have sensible defaults and can be customized as needed.
///
/// See also:
/// - [TypeMate.startOverlayService] for using the configuration
/// - Individual property documentation for detailed options
class OverlayConfig {
  /// Whether to show the bubble automatically when text fields are focused.
  final bool autoShow;

  /// Duration in milliseconds for auto-hide (0 means never auto-hide).
  final int autoHideDuration;

  /// Whether to vibrate when the bubble appears.
  final bool enableVibration;

  /// Custom background color for the bubble (hex string, e.g., "#FF5722").
  final String? bubbleColor;

  /// The size of the overlay bubble in dp.
  final double bubbleSize;

  /// The opacity of the overlay bubble (0.0 to 1.0).
  final double bubbleOpacity;

  /// Whether to enable spell checking feature.
  final bool enableSpellCheck;

  /// Whether to enable grammar checking feature.
  final bool enableGrammarCheck;

  /// Initial X position of the bubble on screen.
  final int initialX;

  /// Initial Y position of the bubble on screen.
  final int initialY;

  const OverlayConfig({
    this.autoShow = true,
    this.autoHideDuration = 3000,
    this.enableVibration = false,
    this.bubbleColor,
    this.bubbleSize = 56.0,
    this.bubbleOpacity = 0.9,
    this.enableSpellCheck = true,
    this.enableGrammarCheck = true,
    this.initialX = 100,
    this.initialY = 200,
  });

  /// Creates a copy of this config with the given fields replaced.
  OverlayConfig copyWith({
    bool? autoShow,
    int? autoHideDuration,
    bool? enableVibration,
    String? bubbleColor,
    double? bubbleSize,
    double? bubbleOpacity,
    bool? enableSpellCheck,
    bool? enableGrammarCheck,
    int? initialX,
    int? initialY,
  }) {
    return OverlayConfig(
      autoShow: autoShow ?? this.autoShow,
      autoHideDuration: autoHideDuration ?? this.autoHideDuration,
      enableVibration: enableVibration ?? this.enableVibration,
      bubbleColor: bubbleColor ?? this.bubbleColor,
      bubbleSize: bubbleSize ?? this.bubbleSize,
      bubbleOpacity: bubbleOpacity ?? this.bubbleOpacity,
      enableSpellCheck: enableSpellCheck ?? this.enableSpellCheck,
      enableGrammarCheck: enableGrammarCheck ?? this.enableGrammarCheck,
      initialX: initialX ?? this.initialX,
      initialY: initialY ?? this.initialY,
    );
  }

  /// Converts this config to a map for platform communication.
  Map<String, dynamic> toMap() {
    return {
      'autoShow': autoShow,
      'autoHideDuration': autoHideDuration,
      'enableVibration': enableVibration,
      'bubbleColor': bubbleColor,
      'bubbleSize': bubbleSize,
      'bubbleOpacity': bubbleOpacity,
      'enableSpellCheck': enableSpellCheck,
      'enableGrammarCheck': enableGrammarCheck,
      'initialX': initialX,
      'initialY': initialY,
    };
  }

  /// Creates an OverlayConfig from a map.
  factory OverlayConfig.fromMap(Map<String, dynamic> map) {
    return OverlayConfig(
      autoShow: map['autoShow'] ?? true,
      autoHideDuration: map['autoHideDuration'] ?? 3000,
      enableVibration: map['enableVibration'] ?? false,
      bubbleColor: map['bubbleColor'],
      bubbleSize: map['bubbleSize']?.toDouble() ?? 56.0,
      bubbleOpacity: map['bubbleOpacity']?.toDouble() ?? 0.9,
      enableSpellCheck: map['enableSpellCheck'] ?? true,
      enableGrammarCheck: map['enableGrammarCheck'] ?? true,
      initialX: map['initialX'] ?? 100,
      initialY: map['initialY'] ?? 200,
    );
  }

  @override
  String toString() {
    return 'OverlayConfig(autoShow: $autoShow, autoHideDuration: $autoHideDuration, enableVibration: $enableVibration, bubbleColor: $bubbleColor, bubbleSize: $bubbleSize, bubbleOpacity: $bubbleOpacity, enableSpellCheck: $enableSpellCheck, enableGrammarCheck: $enableGrammarCheck, initialX: $initialX, initialY: $initialY)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OverlayConfig &&
        other.autoShow == autoShow &&
        other.autoHideDuration == autoHideDuration &&
        other.enableVibration == enableVibration &&
        other.bubbleColor == bubbleColor &&
        other.bubbleSize == bubbleSize &&
        other.bubbleOpacity == bubbleOpacity &&
        other.enableSpellCheck == enableSpellCheck &&
        other.enableGrammarCheck == enableGrammarCheck &&
        other.initialX == initialX &&
        other.initialY == initialY;
  }

  @override
  int get hashCode {
    return autoShow.hashCode ^
        autoHideDuration.hashCode ^
        enableVibration.hashCode ^
        bubbleColor.hashCode ^
        bubbleSize.hashCode ^
        bubbleOpacity.hashCode ^
        enableSpellCheck.hashCode ^
        enableGrammarCheck.hashCode ^
        initialX.hashCode ^
        initialY.hashCode;
  }
}
