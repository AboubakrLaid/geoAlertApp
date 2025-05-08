import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/data/repositories/reply_repository_impl.dart';
import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/reply_repository.dart';
import 'package:geoalert/domain/usecases/get_reply_usecase.dart';
import 'package:geoalert/presentation/providers/auth_provider.dart'; // for apiClientProvider

final replyRepositoryProvider = Provider<ReplyRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ReplyRepositoryImpl(apiClient);
});

final getReplyUseCaseProvider = Provider<GetReplyUseCase>((ref) {
  final repository = ref.read(replyRepositoryProvider);
  return GetReplyUseCase(repository);
});

final replyProvider = StateNotifierProvider<ReplyNotifier, AsyncValue<Reply?>>((ref) => ReplyNotifier(ref.read(getReplyUseCaseProvider)));

class ReplyNotifier extends StateNotifier<AsyncValue<Reply?>> {
  final GetReplyUseCase _getReplyUseCase;

  ReplyNotifier(this._getReplyUseCase) : super(const AsyncValue.data(null));

  // a set of fetch replies for a specific alert, so I don't have to call the API every time
  final Map<Map<String, Object>, AsyncValue<Reply?>> _replyCache = {};

  Future<void> fetchReply({required String alertId, required int userId, required int notificationId}) async {
    state = const AsyncValue.loading();
    try {
      final reply = await _getReplyUseCase.execute(alertId: alertId, userId: userId, notificationId: notificationId);
      state = AsyncValue.data(reply);
      _replyCache[{'alertId': alertId, 'userId': userId, 'notificationId': notificationId}] = state;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      _replyCache.remove({'alertId': alertId, 'userId': userId, 'notificationId': notificationId});
    }
  }

  // check if the reply is already in the cache
  bool isReplyCached({required String alertId, required int userId, required int notificationId}) {
    return _replyCache.containsKey({'alertId': alertId, 'userId': userId, 'notificationId': notificationId});
  }
}
