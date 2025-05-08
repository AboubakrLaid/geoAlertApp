class Reply {
  final String? text;
  final String? audioFilePath; // Specify a type if you know it (like String or Uint8List)
  final String? audioUrl;
  final String alertId;
  final int userId;
  final int notificationId;
  final String replyType;
  final DateTime? createdAt;

  Reply({required this.alertId, required this.userId, required this.notificationId, required this.text, required this.replyType, this.audioFilePath, this.audioUrl, this.createdAt});
}
