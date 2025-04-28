import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/data/repositories/alert_repository_impl.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/alert_repository.dart';
import 'package:geoalert/domain/usecases/get_alerts_usecase.dart';
import 'package:geoalert/domain/usecases/reply_to_alert_usecase.dart';
import 'package:geoalert/presentation/providers/auth_provider.dart'; // for apiClientProvider

// Repository Provider
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AlertRepositoryImpl(apiClient);
});

// Use Cases Providers
final getAlertsUseCaseProvider = Provider<GetAlertsUseCase>((ref) {
  final repository = ref.read(alertRepositoryProvider);
  return GetAlertsUseCase(repository);
});

final replyToAlertUseCaseProvider = Provider<ReplyToAlertUseCase>((ref) {
  final repository = ref.read(alertRepositoryProvider);
  return ReplyToAlertUseCase(repository);
});

// State Notifier
final alertProvider = StateNotifierProvider<AlertNotifier, AsyncValue<List<Alert>>>((ref) => AlertNotifier(ref.read(getAlertsUseCaseProvider)));

class AlertNotifier extends StateNotifier<AsyncValue<List<Alert>>> {
  final GetAlertsUseCase _getAlertsUseCase;

  AlertNotifier(this._getAlertsUseCase) : super(const AsyncValue.data([]));

  bool hasFetched = false;

  Future<void> fetchAlerts() async {
    state = const AsyncValue.loading();
    try {
      final alerts = await _getAlertsUseCase.execute();
      state = AsyncValue.data(alerts);
      hasFetched = true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      hasFetched = false;
    }
  }
}

// Reply Notifier
final replyToAlertProvider = StateNotifierProvider<ReplyToAlertNotifier, AsyncValue<void>>((ref) => ReplyToAlertNotifier(ref.read(replyToAlertUseCaseProvider)));

class ReplyToAlertNotifier extends StateNotifier<AsyncValue<void>> {
  final ReplyToAlertUseCase _replyToAlertUseCase;

  ReplyToAlertNotifier(this._replyToAlertUseCase) : super(const AsyncValue.data(null));

  Future<void> reply({required Reply reply}) async {
    state = const AsyncValue.loading();
    try {
      await _replyToAlertUseCase.execute(reply: reply);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }
}
