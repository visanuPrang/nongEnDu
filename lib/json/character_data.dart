class CharacterData {
  final String content;
  final String site;
  final String www;

  CharacterData({required this.content, required this.site, required this.www});

  //อ่านค่า JSON แล้วแปลงให้อยู่ในรูป ViewModel
  factory CharacterData.fromJson(Map<String, dynamic> json) {
    return CharacterData(
        content: json['content'] as String,
        site: json['site'] as String,
        www: json['www'] as String);
  }
}
