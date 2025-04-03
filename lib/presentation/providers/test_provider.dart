import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/data/repositories/test_repository_impl.dart';
import 'package:geoalert/domain/repositories/test_repository.dart';
import 'package:geoalert/domain/usecases/test_usecase.dart';
import 'package:geoalert/presentation/providers/auth_provider.dart';

final testRepositoryProvider = Provider<TestRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return TestRepositoryImpl(apiClient);
});

final testUseCaseProvider = Provider<TestUseCase>((ref) {
  final testRepository = ref.read(testRepositoryProvider);
  return TestUseCase(testRepository);
});

final testProvider = StateNotifierProvider<TestNotifier, AsyncValue<String?>>((ref) => TestNotifier(ref.read(testUseCaseProvider)));

class TestNotifier extends StateNotifier<AsyncValue<String?>> {
  final TestUseCase _testUseCase;

  TestNotifier(this._testUseCase) : super(const AsyncValue.data(null));

  Future<void> callProtected() async {
    state = const AsyncValue.loading();
    try {
      await _testUseCase.execute();
      state = const AsyncValue.data("We got data here");
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }
}
