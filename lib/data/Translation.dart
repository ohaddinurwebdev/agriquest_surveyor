class Translation {
  String englishText;
  String translation;

  Translation({this.englishText, this.translation});

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      englishText: map['english_text'],
      translation: map['translation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'english_text': englishText,
      'translation': translation,
    };
  }
}
