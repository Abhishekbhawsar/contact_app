import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class InternetProvider extends ChangeNotifier {
  InternetProvider({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;
  bool _hasChecked = false;

  bool get isOnline => _isOnline;
  bool get isOffline => _hasChecked && !_isOnline;
  bool get hasChecked => _hasChecked;

  Future<void> startMonitoring() async {
    final initialResult = await _connectivity.checkConnectivity();
    _updateStatus(initialResult);
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    _hasChecked = true;
    _isOnline = results.any((result) => result != ConnectivityResult.none);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
