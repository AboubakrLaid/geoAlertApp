import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/data/repositories/alert_repository_impl.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/alert_repository.dart';
import 'package:geoalert/domain/usecases/check_new_notifications_usecase.dart';
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

final newNotificationUseCaseProvider = Provider<CheckNewNotificationsUsecase>((ref) {
  final repository = ref.read(alertRepositoryProvider);
  return CheckNewNotificationsUsecase(repository);
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

  void updateAlert(Alert updatedAlert) {
    final currentAlerts = state.value ?? [];
    final updatedAlerts = currentAlerts.map((alert) => alert.id == updatedAlert.id ? updatedAlert : alert).toList();
    state = AsyncValue.data(updatedAlerts);
    print("Updated alert: ${updatedAlert.title}");
  }

  void disableAlerts({required String alertId}) {
    final currentAlerts = state.value ?? [];
    final updatedAlerts =
        currentAlerts.map((alert) {
          if (alert.id == alertId && !alert.beenRepliedTo) {
            return alert.copyWith(isDisabled: true);
          }
          return alert;
        }).toList();
    state = AsyncValue.data(updatedAlerts);
    print("Disabled alert with ID: $alertId");
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

final checkNewNotificationsProvider = StateNotifierProvider<CheckNewNotificationsNotifier, AsyncValue<bool>>((ref) => CheckNewNotificationsNotifier(ref.read(newNotificationUseCaseProvider)));

class CheckNewNotificationsNotifier extends StateNotifier<AsyncValue<bool>> {
  final CheckNewNotificationsUsecase _checkNewNotificationsUsecase;

  CheckNewNotificationsNotifier(this._checkNewNotificationsUsecase) : super(const AsyncValue.data(false));

  Future<bool> checkNewNotifications({required String lastCheckedDate}) async {
    state = const AsyncValue.loading();
    try {
      final hasNewNotifications = await _checkNewNotificationsUsecase.execute(lastCheckedDate: lastCheckedDate);
      state = AsyncValue.data(hasNewNotifications);
      return hasNewNotifications;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      return false;
    }
  }
}
