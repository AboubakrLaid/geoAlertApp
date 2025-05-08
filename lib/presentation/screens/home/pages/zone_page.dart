import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/domain/entities/zzone.dart';
import 'package:geoalert/presentation/providers/zone_provider.dart';

class ZoneCard extends StatelessWidget {
  final Zzone zone;

  const ZoneCard({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(zone.name, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), ...zone.coordinates.map((c) => Text('Lat: ${c.latitude}, Lng: ${c.longitude}'))],
        ),
      ),
    );
  }
}

class ZonePage extends ConsumerStatefulWidget {
  const ZonePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ZonePageState();
}

class _ZonePageState extends ConsumerState<ZonePage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getZones();
    });
  }

  Future<void> _getZones() async {
    final notifier = ref.read(zonesProvider.notifier);
    if (!notifier.hasFetched) {
      await notifier.fetchZones();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final zonesState = ref.watch(zonesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(zonesProvider.notifier).fetchZones(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: zonesState.when(
                data: (zones) {
                  if (zones.isEmpty) {
                    return const SliverFillRemaining(child: Center(child: Text("No zones available")));
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final z = zones[index];
                      return Column(
                        children: [
                          ZoneCard(zone: z),
                          if (index < zones.length - 1) Column(children: const [SizedBox(height: 16), Divider(height: 1, thickness: 1, color: Color(0xFFD0D5DD)), SizedBox(height: 16)]),
                        ],
                      );
                    }, childCount: zones.length),
                  );
                },
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error:
                    (error, stackTrace) => SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Failed to load zones'),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: () => ref.read(zonesProvider.notifier).fetchZones(), child: const Text('Retry')),
                          ],
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
