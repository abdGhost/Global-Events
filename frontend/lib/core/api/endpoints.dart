/// API path constants (no base URL).
class Endpoints {
  Endpoints._();

  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authMe = '/api/auth/me';
  static const String authMeTimezone = '/api/auth/me';

  static const String eventsTrending = '/api/events/trending';
  static const String eventsSearch = '/api/events/search';
  static const String eventsNearby = '/api/events/nearby';
  /// Prefer /api/me/... so production never treats "created" as {event_id}.
  static const String eventsCreated = '/api/me/events/created';
  static const String eventsRsvped = '/api/me/events/rsvped';
  static const String eventsCreate = '/api/events';
  static String eventDetail(String id) => '/api/events/$id';
  static String eventRsvp(String id) => '/api/events/$id/rsvp';
  static String eventChatMessages(String id) => '/api/events/$id/chat/messages';
  static String eventChatWebSocket(String id) =>
      '/api/events/$id/chat/ws'; // ws path (not yet used)
}
