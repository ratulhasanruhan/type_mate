# TypeMate Plugin Testing Guide

This guide provides comprehensive information about testing the TypeMate plugin, including unit tests, integration tests, and manual testing procedures.

## Test Structure Overview

The TypeMate plugin includes three types of tests:

### 1. Unit Tests (`test/`)
- **Purpose**: Test individual components in isolation
- **Location**: `test/` directory
- **Coverage**: Core functionality, business logic, and data models

### 2. Integration Tests (`integration_test/`)
- **Purpose**: Test plugin functionality on real devices
- **Location**: `integration_test/` directory  
- **Coverage**: Platform channel communication and system integration

### 3. Manual Tests
- **Purpose**: Test user experience and system-level features
- **Coverage**: Permissions, services, and cross-app functionality

## Running Tests

### Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/type_mate_test.dart

# Run tests with coverage
flutter test --coverage
```

### Integration Tests

```bash
# Run integration tests on connected device
flutter test integration_test/type_mate_integration_test.dart

# Run with specific device
flutter test integration_test/ -d device_id
```

### Test Coverage

```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Files Description

### `test/type_mate_test.dart`
**Main plugin functionality tests**

- ✅ Singleton pattern verification
- ✅ Plugin initialization and disposal
- ✅ Permission management (overlay, accessibility)
- ✅ Service management (start, stop, test)
- ✅ Event streams (text field focus/unfocus)
- ✅ Quick setup functionality
- ✅ Status monitoring
- ✅ Error handling and edge cases

**Key Test Groups:**
- `Singleton Pattern`: Ensures only one instance exists
- `Initialization`: Tests plugin setup and teardown
- `Permission Management`: Verifies permission checking and requests
- `Service Management`: Tests overlay service lifecycle
- `Event Streams`: Tests broadcast streams and multiple listeners
- `Quick Setup`: Tests automated setup process
- `Status Monitoring`: Tests comprehensive status reporting

### `test/overlay_config_test.dart`
**Configuration model tests**

- ✅ Constructor with default and custom values
- ✅ `copyWith` method functionality
- ✅ Serialization (toMap/fromMap)
- ✅ Equality and hash code
- ✅ String representation
- ✅ Data validation
- ✅ Round-trip serialization integrity

**Key Test Groups:**
- `Constructor`: Tests creation with various parameters
- `copyWith`: Tests immutable updates
- `Serialization`: Tests JSON conversion
- `Equality`: Tests value equality
- `Validation`: Tests parameter validation
- `Round-trip Serialization`: Tests data integrity

### `test/type_mate_method_channel_test.dart`
**Platform channel communication tests**

- ✅ Method channel calls with correct parameters
- ✅ Error handling for platform exceptions
- ✅ Null return value handling
- ✅ Text field focus listener callbacks
- ✅ Concurrent method calls
- ✅ Method channel configuration

**Key Test Groups:**
- `Permission Methods`: Tests permission-related calls
- `Service Methods`: Tests service control calls
- `Error Handling`: Tests exception scenarios
- `Text Field Focus Listeners`: Tests callback mechanisms
- `Method Channel Configuration`: Tests channel setup
- `Async Operation Handling`: Tests concurrent operations

### `integration_test/type_mate_integration_test.dart`
**Real device integration tests**

- ✅ Plugin initialization on real devices
- ✅ Permission checking without errors
- ✅ Service management functionality
- ✅ Event stream functionality
- ✅ Error handling in real environment
- ✅ Performance with rapid calls
- ✅ Cleanup and disposal

**Key Test Groups:**
- `Plugin Initialization`: Tests real device initialization
- `Permission Checking`: Tests actual permission states
- `Permission Requests`: Tests system permission dialogs
- `Service Management`: Tests real service operations
- `Event Streams`: Tests stream functionality
- `Quick Setup`: Tests complete setup flow
- `Status Monitoring`: Tests real status reporting
- `Error Handling`: Tests real-world error scenarios
- `Cleanup and Disposal`: Tests resource cleanup
- `Platform Specific Tests`: Tests Android-specific features
- `Performance Tests`: Tests under load

## Manual Testing Procedures

### Prerequisites
1. Android device with API level 21+
2. USB debugging enabled
3. Connected device or emulator

### Test Scenarios

#### 1. Permission Flow Testing
```bash
# Start the example app
cd example
flutter run
```

**Test Steps:**
1. ✅ Tap "Quick Setup" button
2. ✅ Verify overlay permission request appears
3. ✅ Grant overlay permission
4. ✅ Verify accessibility settings open
5. ✅ Enable TypeMate accessibility service
6. ✅ Return to app and verify all permissions granted
7. ✅ Verify service starts automatically

#### 2. Cross-App Functionality Testing
**Test Steps:**
1. ✅ Start TypeMate service in example app
2. ✅ Open another app (e.g., WhatsApp, Notes)
3. ✅ Tap on text field
4. ✅ Verify TypeMate bubble appears
5. ✅ Test bubble interactions (Check, Fix, Close)
6. ✅ Verify bubble disappears after timeout
7. ✅ Test in multiple apps

#### 3. Service Lifecycle Testing
**Test Steps:**
1. ✅ Start overlay service
2. ✅ Verify persistent notification appears
3. ✅ Test overlay in external apps
4. ✅ Stop overlay service
5. ✅ Verify notification disappears
6. ✅ Verify overlay no longer appears in apps
7. ✅ Restart service and verify functionality restored

#### 4. Performance Testing
**Test Steps:**
1. ✅ Start service with multiple apps open
2. ✅ Rapidly switch between text fields
3. ✅ Monitor memory usage
4. ✅ Test for 30+ minutes continuous use
5. ✅ Verify no memory leaks
6. ✅ Test battery impact

#### 5. Error Scenario Testing
**Test Steps:**
1. ✅ Revoke overlay permission while service running
2. ✅ Disable accessibility service while active
3. ✅ Force-close example app while service running
4. ✅ Restart device with service enabled
5. ✅ Test with low memory conditions

### Expected Results

#### Successful Test Criteria
- ✅ All unit tests pass
- ✅ All integration tests pass
- ✅ No crashes during manual testing
- ✅ Bubble appears consistently across apps
- ✅ Permissions are handled gracefully
- ✅ Service survives app restarts
- ✅ Memory usage remains stable
- ✅ No UI blocking or stuttering

#### Performance Benchmarks
- **Memory usage**: < 50MB additional when active
- **Response time**: Bubble appears within 500ms of text field focus
- **Battery impact**: < 5% additional drain per hour
- **CPU usage**: < 2% when idle, < 10% during active use

## Test Data and Mock Objects

### Mock Platform Implementation
The `MockTypeMatePlatform` class provides:
- Controllable return values for all methods
- Method call tracking for verification
- Event simulation capabilities
- Error scenario simulation

### Test Utilities
- Stream testing helpers
- Async operation verification
- Mock state management
- Event timing verification

## Continuous Integration

### GitHub Actions (Recommended)
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter test integration_test/
```

### Test Automation
- Unit tests should run on every commit
- Integration tests should run on pull requests
- Manual testing should be performed before releases

## Debugging Test Failures

### Common Issues and Solutions

#### 1. Platform Channel Communication Errors
```dart
// Enable verbose logging
debugPrint('Method channel call: ${call.method}');
```

#### 2. Stream Subscription Errors
```dart
// Ensure proper cleanup
await subscription.cancel();
```

#### 3. Permission Test Failures
```dart
// Check Android API level compatibility
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
  // API 23+ permission logic
}
```

#### 4. Integration Test Timeouts
```dart
// Increase timeout for slow devices
await tester.pumpAndSettle(Duration(seconds: 10));
```

### Debug Logging
Enable debug logging in the plugin:
```dart
// In plugin code
debugPrint('TypeMate: Service started');
```

### Test Isolation
Ensure tests don't interfere with each other:
```dart
setUp(() {
  // Reset state before each test
});

tearDown(() {
  // Clean up after each test
});
```

## Contributing Tests

### Guidelines for New Tests
1. **Test Naming**: Use descriptive names explaining the scenario
2. **Test Structure**: Follow Arrange-Act-Assert pattern
3. **Mock Usage**: Use mocks for external dependencies
4. **Error Testing**: Include both success and failure cases
5. **Documentation**: Add comments for complex test logic

### Test Categories
- **Happy Path**: Normal usage scenarios
- **Edge Cases**: Boundary conditions and unusual inputs
- **Error Handling**: Exception scenarios and recovery
- **Performance**: Load and stress testing
- **Integration**: Cross-component functionality

### Code Coverage Goals
- **Unit Tests**: > 90% line coverage
- **Integration Tests**: > 80% feature coverage
- **Manual Tests**: 100% user journey coverage

## Troubleshooting

### Test Environment Issues
1. **Flutter SDK Version**: Ensure compatible version
2. **Android SDK**: API level 21+ required
3. **Device Setup**: USB debugging enabled
4. **Emulator Config**: Hardware acceleration enabled

### Test Execution Issues
1. **Dependencies**: Run `flutter pub get`
2. **Clean Build**: Run `flutter clean`
3. **Device Connection**: Verify with `flutter devices`
4. **Test Isolation**: Run tests individually if needed

### Platform-Specific Issues
1. **Android Permissions**: Check manifest configuration
2. **Service Registration**: Verify service declarations
3. **Resource Access**: Ensure proper resource paths
4. **Native Code**: Check Kotlin compilation

---

## Summary

The TypeMate plugin includes comprehensive testing at multiple levels:
- **Unit Tests**: Fast, isolated component testing
- **Integration Tests**: Real device functionality testing  
- **Manual Tests**: User experience and system integration testing

This multi-layered approach ensures reliability, performance, and compatibility across different Android devices and API levels.

For questions or issues with testing, refer to the main README.md or open an issue in the repository.