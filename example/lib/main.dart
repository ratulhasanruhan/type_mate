import 'dart:async';
import 'package:flutter/material.dart';
import 'package:type_mate/type_mate.dart';

void main() {
  runApp(const TypeMateExampleApp());
}

class TypeMateExampleApp extends StatelessWidget {
  const TypeMateExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TypeMate Plugin Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      home: const TypeMateHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TypeMateHomePage extends StatefulWidget {
  const TypeMateHomePage({super.key});

  @override
  State<TypeMateHomePage> createState() => _TypeMateHomePageState();
}

class _TypeMateHomePageState extends State<TypeMateHomePage> {
  // Plugin state
  bool _isInitialized = false;
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityService = false;
  bool _isOverlayActive = false;

  // UI state
  Timer? _statusTimer;
  int _textFieldFocusCount = 0;
  String _lastEventTime = 'Never';
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    _initializePlugin();
    _startStatusTimer();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    TypeMate.instance.dispose();
    super.dispose();
  }

  Future<void> _initializePlugin() async {
    try {
      final initialized = await TypeMate.instance.initialize();
      setState(() {
        _isInitialized = initialized;
      });

      if (initialized) {
        _checkPermissions();
        _setupListeners();
        _addLog('Plugin initialized successfully');
      } else {
        _addLog('Failed to initialize plugin');
      }
    } catch (e) {
      _addLog('Error initializing plugin: $e');
    }
  }

  void _setupListeners() {
    TypeMate.instance.textFieldFocusedStream.listen((_) {
      setState(() {
        _textFieldFocusCount++;
        _lastEventTime = DateTime.now().toString().split('.')[0];
      });
      _addLog('Text field focused in external app');
    });

    TypeMate.instance.textFieldUnfocusedStream.listen((_) {
      _addLog('Text field unfocused in external app');
    });
  }

  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _isInitialized) {
        _checkPermissions();
      }
    });
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().split('.')[0];
    setState(() {
      _eventLog.insert(0, '[$timestamp] $message');
      if (_eventLog.length > 50) {
        _eventLog.removeRange(50, _eventLog.length);
      }
    });
  }

  Future<void> _checkPermissions() async {
    try {
      final overlayPermission = await TypeMate.instance
          .checkOverlayPermission();
      final accessibilityService = await TypeMate.instance
          .checkAccessibilityService();

      setState(() {
        _hasOverlayPermission = overlayPermission;
        _hasAccessibilityService = accessibilityService;
      });
    } catch (e) {
      _addLog('Error checking permissions: $e');
    }
  }

  Future<void> _requestOverlayPermission() async {
    try {
      await TypeMate.instance.requestOverlayPermission();
      _addLog('Overlay permission requested');
      await Future.delayed(const Duration(seconds: 1));
      await _checkPermissions();
    } catch (e) {
      _addLog('Error requesting overlay permission: $e');
    }
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await TypeMate.instance.openAccessibilitySettings();
      _addLog('Accessibility settings opened');
    } catch (e) {
      _addLog('Error opening accessibility settings: $e');
    }
  }

  Future<void> _startOverlayService() async {
    try {
      await TypeMate.instance.startOverlayService();
      setState(() {
        _isOverlayActive = true;
      });
      _addLog('Overlay service started successfully');
    } catch (e) {
      _addLog('Error starting overlay service: $e');
    }
  }

  Future<void> _stopOverlayService() async {
    try {
      await TypeMate.instance.stopOverlayService();
      setState(() {
        _isOverlayActive = false;
      });
      _addLog('Overlay service stopped');
    } catch (e) {
      _addLog('Error stopping overlay service: $e');
    }
  }

  Future<void> _testOverlay() async {
    try {
      await TypeMate.instance.testOverlay();
      _addLog('Test overlay triggered - bubble should appear for 3 seconds');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test overlay triggered! Check for the bubble.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _addLog('Error testing overlay: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing overlay: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _quickSetup() async {
    try {
      _addLog('Starting quick setup...');
      final result = await TypeMate.instance.quickSetup();

      setState(() {
        _isInitialized = result['initialized'] ?? false;
        _hasOverlayPermission = result['hasOverlayPermission'] ?? false;
        _hasAccessibilityService = result['hasAccessibilityService'] ?? false;
        _isOverlayActive = result['serviceStarted'] ?? false;
      });

      String message;
      if (result['serviceStarted'] == true) {
        message = 'TypeMate is ready! The overlay service is now active.';
        _addLog('Quick setup completed successfully');
      } else if (!result['hasOverlayPermission']!) {
        message = 'Please grant overlay permission and try again.';
        _addLog('Quick setup failed: Missing overlay permission');
      } else if (!result['hasAccessibilityService']!) {
        message = 'Please enable the accessibility service and try again.';
        _addLog('Quick setup failed: Missing accessibility service');
      } else {
        message = 'Setup failed. Please check permissions manually.';
        _addLog('Quick setup failed: Unknown error');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: result['serviceStarted'] == true
              ? Colors.green
              : Colors.orange,
        ),
      );
    } catch (e) {
      _addLog('Error in quick setup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TypeMate Plugin Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TypeMate Plugin Example',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'System-wide Writing Assistant Demo',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildStatusRow('Plugin Initialized', _isInitialized),
                    _buildStatusRow(
                      'Overlay Permission',
                      _hasOverlayPermission,
                    ),
                    _buildStatusRow(
                      'Accessibility Service',
                      _hasAccessibilityService,
                    ),
                    _buildStatusRow('Overlay Active', _isOverlayActive),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Setup Button
            ElevatedButton.icon(
              onPressed: _quickSetup,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Quick Setup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Permissions Section
            if (_isInitialized) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permissions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionRow(
                        'Overlay Permission',
                        _hasOverlayPermission,
                        _requestOverlayPermission,
                      ),
                      const SizedBox(height: 8),
                      _buildPermissionRow(
                        'Accessibility Service',
                        _hasAccessibilityService,
                        _openAccessibilitySettings,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Service Control
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Control',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isOverlayActive
                            ? _stopOverlayService
                            : _startOverlayService,
                        icon: Icon(
                          _isOverlayActive ? Icons.stop : Icons.play_arrow,
                        ),
                        label: Text(
                          _isOverlayActive ? 'Stop Overlay' : 'Start Overlay',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _isOverlayActive
                              ? Colors.red
                              : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _testOverlay,
                        icon: const Icon(Icons.science),
                        label: const Text('Test Overlay'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Statistics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Events',
                              _textFieldFocusCount.toString(),
                              Icons.text_fields,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Last Event',
                              _lastEventTime.split(' ').length > 1
                                  ? _lastEventTime.split(' ')[1]
                                  : _lastEventTime,
                              Icons.access_time,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Event Log
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Event Log',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _eventLog.clear();
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _eventLog.isEmpty
                            ? const Center(child: Text('No events logged yet'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _eventLog.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      _eventLog[index],
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Test Area
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Area',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type in these fields to test overlay functionality:',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Test Text Field',
                        hintText: 'Type here to test the overlay...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Multi-line Text Field',
                        hintText: 'Type a longer message here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Use TypeMate',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '1. Click "Quick Setup" to initialize everything\n'
                      '2. Grant overlay permission when prompted\n'
                      '3. Enable accessibility service in settings\n'
                      '4. Start the overlay service\n'
                      '5. Open any app and type in text fields\n'
                      '6. The bubble will appear when you focus on text fields!',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String title, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: status ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Text(
              status ? 'Ready' : 'Not Ready',
              style: TextStyle(
                color: status ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(
    String title,
    bool hasPermission,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasPermission ? Colors.green : Colors.orange,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: hasPermission
            ? Colors.green.withOpacity(0.05)
            : Colors.orange.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.warning,
            color: hasPermission ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          if (!hasPermission)
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Grant'),
            )
          else
            Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
