import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'config.dart';
import 'offline_view.dart';

enum _ConnectionStatus { checking, online, offline }

class WebAppWrapper extends StatefulWidget {
  const WebAppWrapper({super.key});

  @override
  State<WebAppWrapper> createState() => _WebAppWrapperState();
}

class _WebAppWrapperState extends State<WebAppWrapper> {
  late final WebViewController _controller;
  final InternetConnection _internet = InternetConnection();
  StreamSubscription<InternetStatus>? _statusSubscription;

  _ConnectionStatus _status = _ConnectionStatus.checking;
  bool _isRetrying = false;
  bool _hasLoadedPage = false;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _initConnectivity();
  }

  WebViewController _createController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              _refreshConnectivity();
            }
          },
        ),
      );
  }

  Future<void> _initConnectivity() async {
    final connected = await _internet.hasInternetAccess;
    if (!mounted) return;

    _applyConnectivity(connected);
    _statusSubscription = _internet.onStatusChange.listen(_onStatusChange);
  }

  void _onStatusChange(InternetStatus status) {
    _applyConnectivity(status == InternetStatus.connected);
  }

  Future<void> _refreshConnectivity() async {
    final connected = await _internet.hasInternetAccess;
    _applyConnectivity(connected);
  }

  Future<void> _onRetryPressed() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    final connected = await _internet.hasInternetAccess;
    if (!mounted) return;

    setState(() => _isRetrying = false);
    _applyConnectivity(connected);
  }

  /// Single source of truth for reacting to a connectivity result: updates
  /// status, lazily loads the page once, and keeps the WebView in the tree.
  void _applyConnectivity(bool connected) {
    if (!mounted) return;

    final shouldLoad = connected && !_hasLoadedPage;
    setState(() {
      _status = connected
          ? _ConnectionStatus.online
          : _ConnectionStatus.offline;
      if (shouldLoad) _hasLoadedPage = true;
    });

    if (shouldLoad) {
      _controller.loadRequest(Uri.parse(homeUrl));
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_hasLoadedPage) WebViewWidget(controller: _controller),
            if (_status == _ConnectionStatus.checking)
              ColoredBox(
                color: surface,
                child: const Center(child: CircularProgressIndicator()),
              )
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _status == _ConnectionStatus.online
                    ? const SizedBox.shrink()
                    : OfflineView(
                        isChecking: _isRetrying,
                        onRetry: _onRetryPressed,
                      ),
              ),
          ],
        ),
      ),
    );
  }
}