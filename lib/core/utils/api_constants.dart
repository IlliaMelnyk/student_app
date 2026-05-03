class ApiConstants {
  static const String authUrl =
      'https://auth.citymind.tech/realms/citymind/protocol/openid-connect';
  static const String loginEndpoint = '$authUrl/token/';
  // static const String reportsBaseUrl = 'http://localhost:1910';
  static const String chatbotUrl = 'https://api.citymind.tech/get';
  static const String communityBoardBaseUrl =
      'https://api.manager.citymind.tech/community-board';
  static const String publicReportsUrl =
      'https://api.citymind.tech/reporting/reports';

  static const String newsBaseUrl =
      'https://api.mm.mendelu.cz/v1/newsfeed/news/all/';
}
