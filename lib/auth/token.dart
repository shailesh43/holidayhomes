import 'dart:convert';

Token tokenFromJson(String str) {
  final jsonData = json.decode(str);
  return Token.fromJson(jsonData);
}

class Token {
  String accessToken;
  String tokenType;
  num? expiresIn;
  String? refreshToken;
  String? idToken;
  String? scope;

  Token({
    required this.accessToken,
    required this.tokenType,
    this.expiresIn,
    this.refreshToken,
    this.idToken,
    this.scope,
  });

  factory Token.fromJson(Map<String, dynamic> json) => Token(
    accessToken: json["access_token"],
    tokenType: json["token_type"],
    expiresIn: json["expires_in"],
    refreshToken: json["refresh_token"],
    idToken: json["id_token"],
    scope: json["scope"],
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "token_type": tokenType,
    "expires_in": expiresIn,
    "refresh_token": refreshToken,
    "id_token": idToken,
    "scope": scope,
  };
}
