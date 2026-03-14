/// Event model matching backend API (UTC times + optional local display).
class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime startUtc;
  final DateTime endUtc;
  final DateTime? startLocal;
  final DateTime? endLocal;
  final String timezone;
  final double? lat;
  final double? lng;
  final String? address;
  final String? city;
  final String? countryCode;
  final bool isVirtual;
  final String? category;
  final String? imageUrl;
  final int? maxAttendees;
  final bool isApproved;
  final String createdBy;
  final DateTime createdAt;
  final int viewsCount;
  final int rsvpCount;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.startUtc,
    required this.endUtc,
    this.startLocal,
    this.endLocal,
    required this.timezone,
    this.lat,
    this.lng,
    this.address,
    this.city,
    this.countryCode,
    required this.isVirtual,
    this.category,
    this.imageUrl,
    this.maxAttendees,
    required this.isApproved,
    required this.createdBy,
    required this.createdAt,
    required this.viewsCount,
    required this.rsvpCount,
  });

  /// Display time: prefer [startLocal] if present (from ?tz= or X-Timezone), else [startUtc] in local.
  DateTime get displayStart => startLocal ?? startUtc.toLocal();
  DateTime get displayEnd => endLocal ?? endUtc.toLocal();

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startUtc: DateTime.parse(json['start_utc'] as String),
      endUtc: DateTime.parse(json['end_utc'] as String),
      startLocal: json['start_local'] != null
          ? DateTime.parse(json['start_local'] as String)
          : null,
      endLocal: json['end_local'] != null
          ? DateTime.parse(json['end_local'] as String)
          : null,
      timezone: json['timezone'] as String? ?? 'UTC',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      isVirtual: json['is_virtual'] as bool? ?? false,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      maxAttendees: json['max_attendees'] as int?,
      isApproved: json['is_approved'] as bool? ?? true,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      viewsCount: json['views_count'] as int? ?? 0,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_utc': startUtc.toUtc().toIso8601String(),
      'end_utc': endUtc.toUtc().toIso8601String(),
      'start_local': startLocal?.toIso8601String(),
      'end_local': endLocal?.toIso8601String(),
      'timezone': timezone,
      'lat': lat,
      'lng': lng,
      'address': address,
      'city': city,
      'country_code': countryCode,
      'is_virtual': isVirtual,
      'category': category,
      'image_url': imageUrl,
      'max_attendees': maxAttendees,
      'is_approved': isApproved,
      'created_by': createdBy,
      'created_at': createdAt.toUtc().toIso8601String(),
      'views_count': viewsCount,
      'rsvp_count': rsvpCount,
    };
  }
}

/// List item (summary) from trending / search / nearby.
class EventListItem {
  final String id;
  final String title;
  final DateTime startUtc;
  final DateTime endUtc;
  final String timezone;
  final double? lat;
  final double? lng;
  final String? address;
  final String? city;
  final String? countryCode;
  final bool isVirtual;
  final String? category;
  final String? imageUrl;
  final int rsvpCount;
  final int viewsCount;

  const EventListItem({
    required this.id,
    required this.title,
    required this.startUtc,
    required this.endUtc,
    required this.timezone,
    this.lat,
    this.lng,
    this.address,
    this.city,
    this.countryCode,
    required this.isVirtual,
    this.category,
    this.imageUrl,
    required this.rsvpCount,
    required this.viewsCount,
  });

  factory EventListItem.fromJson(Map<String, dynamic> json) {
    return EventListItem(
      id: json['id'] as String,
      title: json['title'] as String,
      startUtc: DateTime.parse(json['start_utc'] as String),
      endUtc: DateTime.parse(json['end_utc'] as String),
      timezone: json['timezone'] as String? ?? 'UTC',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      isVirtual: json['is_virtual'] as bool? ?? false,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
    );
  }

  /// For persisting saved events (same shape as API / fromJson).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_utc': startUtc.toUtc().toIso8601String(),
      'end_utc': endUtc.toUtc().toIso8601String(),
      'timezone': timezone,
      'lat': lat,
      'lng': lng,
      'address': address,
      'city': city,
      'country_code': countryCode,
      'is_virtual': isVirtual,
      'category': category,
      'image_url': imageUrl,
      'rsvp_count': rsvpCount,
      'views_count': viewsCount,
    };
  }
}

/// Convert full [Event] to list item for cards and saved list.
EventListItem eventToListItem(Event event) {
  return EventListItem(
    id: event.id,
    title: event.title,
    startUtc: event.startUtc,
    endUtc: event.endUtc,
    timezone: event.timezone,
    lat: event.lat,
    lng: event.lng,
    address: event.address,
    city: event.city,
    countryCode: event.countryCode,
    isVirtual: event.isVirtual,
    category: event.category,
    imageUrl: event.imageUrl,
    rsvpCount: event.rsvpCount,
    viewsCount: event.viewsCount,
  );
}
