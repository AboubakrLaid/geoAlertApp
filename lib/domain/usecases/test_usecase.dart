import 'package:geoalert/domain/repositories/test_repository.dart';

class TestUseCase {
  final TestRepository repository;
  TestUseCase(this.repository);

  Future<void> execute() {
    return repository.callProtected();
  }
}
