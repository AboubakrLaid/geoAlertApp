import 'package:geoalert/config/app_config.dart';
import 'package:geoalert/domain/entities/reply.dart';

class ReplyModel extends Reply {
  ReplyModel({required super.alertId, required super.userId, required super.notificationId, required super.text, required super.replyType, super.audioFilePath, super.audioUrl, super.createdAt});

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      text: json['text'] != null ? json['text'] as String : '',
      audioUrl: "${AppConfig.baseUrl}/${json['audio_url']}" as String?,
      alertId: json['alert_id'] as String,
      userId: json['user_id'] as int,
      notificationId: json['notification_id'] as int,
      createdAt: json['reply_date'] != null ? DateTime.parse(json['reply_date']) : null,
      replyType: json['reply_type'] as String,

      audioFilePath: null,
    );
  }
}
