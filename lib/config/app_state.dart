import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppState extends ChangeNotifier {
  ProviderContainer container = ProviderContainer();

  void resetContainer() {
    container.dispose();
    container = ProviderContainer();
    notifyListeners();
  }
}
