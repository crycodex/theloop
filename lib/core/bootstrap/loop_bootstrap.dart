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

  bool? _connected;
  bool _checking = true;
  bool _firebaseReady = false;

  @override
  void initState() {
    super.initState();
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
    final connected = await _connectivity.hasWifiConnection();
    if (!mounted) return;

    if (connected && !_firebaseReady) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseReady = true;
    }

    setState(() {
      _connected = connected;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_connected != true) {
      return NoConnectionScreen(
        settings: widget.initialSettings,
        checking: _checking,
        onRetry: _evaluateConnectivity,
      );
    }

    return LoopApp(
      initialSettings: widget.initialSettings,
      settingsStorage: widget.settingsStorage,
    );
  }
}
