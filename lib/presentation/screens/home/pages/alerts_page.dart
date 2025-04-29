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

class _AlertsPageState extends ConsumerState<AlertsPage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _initializeJiffy();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAlertsIfNeeded();
    });
  }

  Future<void> _initializeJiffy() async {
    await Jiffy.setLocale('en');
  }

  Future<void> _fetchAlertsIfNeeded() async {
    final notifier = ref.read(alertProvider.notifier);
    if (!notifier.hasFetched) {
      await notifier.fetchAlerts();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final alertState = ref.watch(alertProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(alertProvider.notifier).fetchAlerts(),
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
                          if (index < alerts.length - 1) // Don't add divider after last item
                            Column(
                              children: [
                                SizedBox(height: 16),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFD0D5DD), // rgba(208, 213, 221, 1)
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
