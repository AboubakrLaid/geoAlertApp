import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/presentation/screens/home/pages/widgets/no_alert_widget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:geoalert/presentation/providers/alert_provider.dart';
import 'package:geoalert/presentation/screens/home/pages/widgets/alert_card.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  Timer? _newAlertsCheckTimer;
  bool _isCheckingForNewAlerts = false;
  bool _hasNewAlerts = false;

  @override
  void initState() {
    super.initState();
    _initializeJiffy();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAlertsIfNeeded();
    });
  }

  @override
  void dispose() {
    _newAlertsCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForNewAlerts();

      if (_newAlertsCheckTimer == null || !_newAlertsCheckTimer!.isActive) {
        debugPrint('Resuming periodic timer...');
        _startNewAlertsCheckTimer();
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      debugPrint('Pausing periodic timer...');
      _newAlertsCheckTimer?.cancel();
      _newAlertsCheckTimer = null;
    }
  }

  Future<void> _initializeJiffy() async {
    await Jiffy.setLocale('en');
  }

  void _startNewAlertsCheckTimer() {
    // Then check every 30 seconds
    _checkForNewAlerts();
    _newAlertsCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkForNewAlerts();
    });
  }

  Future<void> _fetchAlertsIfNeeded() async {
    final notifier = ref.read(alertProvider.notifier);
    if (!notifier.hasFetched) {
      await notifier.fetchAlerts();
      if (_newAlertsCheckTimer == null) {
        _startNewAlertsCheckTimer();
      }
    }
  }

  Future<void> _checkForNewAlerts() async {
    if (_isCheckingForNewAlerts) return;

    _isCheckingForNewAlerts = true;
    try {
      final alertsNotifier = ref.read(alertProvider.notifier);
      final alerts = alertsNotifier.state.valueOrNull;

      if (alerts == null || alerts.isEmpty) {
        return;
      }

      // Get the date of the most recent alert
      final lastAlertDate = alerts.first.date?.toIso8601String();
      if (lastAlertDate != null) {
        final notifier = ref.read(checkNewNotificationsProvider.notifier);
        final hasNewAlerts = await notifier.checkNewNotifications(lastCheckedDate: lastAlertDate);

        if (hasNewAlerts && mounted) {
          _hasNewAlerts = true;
        }
      }
    } finally {
      _isCheckingForNewAlerts = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final alertState = ref.watch(alertProvider);
    final newAlertsState = ref.watch(checkNewNotificationsProvider);

    ref.listen<AsyncValue<bool>>(checkNewNotificationsProvider, (previous, next) {
      if (next is AsyncData<bool>) {
        _hasNewAlerts = next.value;
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await ref.read(alertProvider.notifier).fetchAlerts();
              await _checkForNewAlerts();
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16),
                  sliver: alertState.when(
                    data: (alerts) {
                      if (alerts.isEmpty) {
                        return SliverFillRemaining(child: NoAlertWidget());
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final alert = alerts[index];
                          return Column(
                            children: [
                              AlertCard(alert: alert),
                              if (index < alerts.length - 1) Column(children: [SizedBox(height: 16), const Divider(height: 1, thickness: 1, color: Color(0xFFD0D5DD)), SizedBox(height: 16)]),
                            ],
                          );
                        }, childCount: alerts.length),
                      );
                    },
                    loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                    error:
                        (error, stackTrace) => SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('Failed to load alerts'), const SizedBox(height: 16), ElevatedButton(onPressed: _fetchAlertsIfNeeded, child: const Text('Retry'))],
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
          // animate the button
          // if (_hasNewAlerts)
          AnimatedOpacity(
            opacity: _hasNewAlerts ? 1.0 : 0.0,
            duration: Duration(milliseconds: 400),
            child: Align(
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(220, 9, 26, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  ref.read(alertProvider.notifier).fetchAlerts();
                  _hasNewAlerts = false;
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    const Text('New Alerts', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
