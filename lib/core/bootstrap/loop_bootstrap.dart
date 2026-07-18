import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../connectivity/connectivity_service.dart';
import '../connectivity/no_connection_screen.dart';
import '../settings/cubit/settings_state.dart';
import '../settings/data/settings_storage.dart';
import '../../firebase_options.dart';
import '../../main.dart' show LoopApp;

class LoopBootstrap extends StatefulWidget {
  const LoopBootstrap({
    super.key,
    required this.initialSettings,
    required this.settingsStorage,
    this.connectivityService,
  });

  final SettingsState initialSettings;
  final SettingsStorage settingsStorage;
  final ConnectivityService? connectivityService;

  @override
  State<LoopBootstrap> createState() => _LoopBootstrapState();
}

class _LoopBootstrapState extends State<LoopBootstrap> {
  late final ConnectivityService _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  late SettingsState _settings;
  bool? _connected;
  bool _checking = true;
  bool _firebaseReady = false;
  Object? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _connectivity = widget.connectivityService ?? ConnectivityService();
    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      _evaluateConnectivity();
    });
    _evaluateConnectivity();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _evaluateConnectivity() async {
    setState(() => _checking = true);
    final settings = await widget.settingsStorage.load();
    final connected = await _connectivity.hasWifiConnection();
    if (!mounted) return;

    if (connected && !_firebaseReady) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _firebaseReady = true;
        _bootstrapError = null;
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _bootstrapError = error;
          _checking = false;
        });
        return;
      }
    }

    setState(() {
      _settings = settings;
      _connected = connected;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'No pudimos iniciar la app. Intenta de nuevo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _bootstrapError = null;
                          _checking = true;
                        });
                        _evaluateConnectivity();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_connected != true) {
      return NoConnectionScreen(
        settingsStorage: widget.settingsStorage,
        checking: _checking,
        onRetry: _evaluateConnectivity,
      );
    }

    return LoopApp(
      initialSettings: _settings,
      settingsStorage: widget.settingsStorage,
    );
  }
}
