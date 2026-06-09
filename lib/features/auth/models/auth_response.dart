class AuthResponse {
  final String token;
  final Map<String, dynamic>? user;
  final Map<String, dynamic> rawData;

  AuthResponse({required this.token, this.user, required this.rawData});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token =
        json['token'] ??
        json['access_token'] ??
        json['data']?['token'] ??
        json['accessToken'] ??
        '';

    final user =
        json['user'] ?? json['data']?['user'] ?? json['data']?['userData'];
    return AuthResponse(token: token, user: user, rawData: json);
  }
}
