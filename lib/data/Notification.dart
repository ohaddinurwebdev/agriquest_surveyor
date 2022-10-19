class FdmsNotification {
  int id;
  String title;
  String message;
  String photos;
  DateTime timestamp;

  FdmsNotification({this.id, this.title, this.message, this.photos, this.timestamp});

  factory FdmsNotification.fromMap(Map<String, dynamic> map) {
    return FdmsNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      photos: map['photos'],
      timestamp: DateTime.parse(map['timestamp'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'photos': photos,
      'timestamp': timestamp.toIso8601String()
    };
  }
}
