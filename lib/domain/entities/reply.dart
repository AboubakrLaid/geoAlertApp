class Reply {
  final String text;
  final dynamic audio; // Specify a type if you know it (like String or Uint8List)
  final int alertId;
  final int userId;
  final int notificationId;
  final String replyType;

  Reply({required this.alertId, required this.userId, required this.notificationId, required this.text, this.audio}) : replyType = audio == null ? 'text' : 'audio';
}
