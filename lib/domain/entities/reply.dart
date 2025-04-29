class Reply {
  final String text;
  final String? audioFilePath; // Specify a type if you know it (like String or Uint8List)
  final int alertId;
  final int userId;
  final int notificationId;
  final String replyType;

  Reply({required this.alertId, required this.userId, required this.notificationId, required this.text, this.audioFilePath}) : replyType = audioFilePath == null ? 'text' : 'audio';
}
