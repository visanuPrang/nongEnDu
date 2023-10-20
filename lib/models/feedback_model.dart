class FeedbackModel {
  int? no;
  String? email;
  String? name;
  String? parents;
  String? id;
  int? iclass;
  int? room;
  String? image;
  int? expire;

  FeedbackModel(
      {this.no,
      this.email,
      this.name,
      this.parents,
      this.id,
      this.iclass,
      this.room,
      this.image,
      this.expire});

  factory FeedbackModel.fromJson(dynamic json) {
    return FeedbackModel(
      no: json['No'],
      email: json['e-Mail'],
      name: json['Name'],
      parents: json['parents'],
      id: json['id'],
      iclass: json['class'],
      room: json['room'],
      image: json['image'],
      expire: json['expire'],
    );
  }

  Map toJson() => {
        "no": no,
        "e_mail": email,
        "name": name,
        "id": id,
        "class": iclass,
        "room": room,
        "image": image,
        "expire": expire,
      };
}
