// To parse this JSON data, do
//
//     final about = aboutFromJson(jsonString);

import 'dart:convert';

List<About> aboutFromJson(String str) =>
    List<About>.from(json.decode(str).map((x) => About.fromJson(x)));

String aboutToJson(List<About> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class About {
  String? content;
  String? site;
  String? www;

  About({
    this.content,
    this.site,
    this.www,
  });

  factory About.fromJson(Map<String, dynamic> json) => About(
        content: json["Content"],
        site: json["Site"],
        www: json["www"],
      );

  Map<String, dynamic> toJson() => {
        "Content": content,
        "Site": site,
        "www": www,
      };
}
