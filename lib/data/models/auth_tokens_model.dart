import 'package:geoalert/domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json["data"]["accessToken"],
      refreshToken: json["data"]["refreshToken"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    };
  }
}