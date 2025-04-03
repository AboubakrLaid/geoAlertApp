import 'package:geoalert/core/network/api_client.dart';

void handleApiException(Object e) {
  if (e is ApiException) {
    print("API Exception: ${e.message}");
    throw e.message; // Rethrow only the message
  } else {
    print("Unexpected Exception: $e");
    throw "An unexpected error occurred"; // Generic error message
  }
}
