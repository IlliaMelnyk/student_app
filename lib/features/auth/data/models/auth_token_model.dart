class AuthTokenModel {
  final String accessToken;

  AuthTokenModel({required this.accessToken});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(accessToken: json['access_token']);
  }
}
