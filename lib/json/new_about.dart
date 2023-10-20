// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

ExchangeRate exchangeRateFromJson(String str) =>
    ExchangeRate.fromJson(jsonDecode(str));

String exchangeRateToJson(ExchangeRate data) => jsonEncode(data.toJson());

class ExchangeRate {
  ExchangeRate({required this.content, required this.site, required this.www});

  String content;
  String site;
  String www;

  factory ExchangeRate.fromJson(Map<String, dynamic> json) => ExchangeRate(
        content: json['Content'],
        site: json['Site'],
        www: json['www'],
      );

  Object? toJson() {
    return null;
  }
}

// Map<String, dynamic> toJson() => {
//       "content": content,
//       "site": site,
//       "www": www,
//     };
