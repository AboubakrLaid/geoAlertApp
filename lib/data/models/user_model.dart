import 'package:geoalert/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["data"]["id"],
      firstName: json["data"]["firstName"], // Updated field
      lastName: json["data"]["lastName"],   // Updated field
      email: json["data"]["email"],
      phoneNumber: json["data"]["phoneNumber"],
      createdAt: DateTime.parse(json["data"]["createdAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "firstName": firstName, // Updated field
      "lastName": lastName,   // Updated field
      "email": email,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
