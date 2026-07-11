/// Gate status enumeration
enum GateStatus {
  open,
  closed,
  likelyToClose,
  unknown,
}

extension GateStatusExtension on GateStatus {
  String get displayName {
    switch (this) {
      case GateStatus.open:
        return 'Open';
      case GateStatus.closed:
        return 'Closed';
      case GateStatus.likelyToClose:
        return 'Likely to Close';
      case GateStatus.unknown:
        return 'Unknown';
    }
  }

  int get value {
    switch (this) {
      case GateStatus.open:
        return 1;
      case GateStatus.closed:
        return 0;
      case GateStatus.likelyToClose:
        return 2;
      case GateStatus.unknown:
        return -1;
    }
  }

  static GateStatus fromValue(int value) {
    switch (value) {
      case 0:
        return GateStatus.closed;
      case 1:
        return GateStatus.open;
      case 2:
        return GateStatus.likelyToClose;
      default:
        return GateStatus.unknown;
    }
  }
}

/// Railway gate model
class RailwayGate {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final GateStatus status;
  final DateTime? lastUpdated;
  final String? description;
  final int estimatedWaitTime; // in minutes
  final bool isOnRoute;

  const RailwayGate({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.lastUpdated,
    this.description,
    this.estimatedWaitTime = 0,
    this.isOnRoute = false,
  });

  factory RailwayGate.fromJson(Map<String, dynamic> json) {
    return RailwayGate(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Gate',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      status: GateStatusExtension.fromValue(json['status'] ?? -1),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : null,
      description: json['description'],
      estimatedWaitTime: json['estimatedWaitTime'] ?? 0,
      isOnRoute: json['isOnRoute'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.value,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'description': description,
      'estimatedWaitTime': estimatedWaitTime,
      'isOnRoute': isOnRoute,
    };
  }

  RailwayGate copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    GateStatus? status,
    DateTime? lastUpdated,
    String? description,
    int? estimatedWaitTime,
    bool? isOnRoute,
  }) {
    return RailwayGate(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      description: description ?? this.description,
      estimatedWaitTime: estimatedWaitTime ?? this.estimatedWaitTime,
      isOnRoute: isOnRoute ?? this.isOnRoute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RailwayGate &&
        other.id == id &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.status == status;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Gate route model
class GateRoute {
  final String id;
  final List<double> startLocation; // [lat, lng]
  final List<double> endLocation; // [lat, lng]
  final List<List<double>> polylinePoints;
  final double distanceKm;
  final int durationMinutes;
  final List<RailwayGate> gatesOnRoute;
  final bool hasAlternateRoute;

  const GateRoute({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMinutes,
    this.gatesOnRoute = const [],
    this.hasAlternateRoute = false,
  });

  factory GateRoute.fromJson(Map<String, dynamic> json) {
    final List<List<double>> polylinePoints = [];
    if (json['polylinePoints'] != null) {
      for (var point in json['polylinePoints']) {
        polylinePoints.add([
          (point[0] as num).toDouble(),
          (point[1] as num).toDouble(),
        ]);
      }
    }

    final List<RailwayGate> gates = [];
    if (json['gatesOnRoute'] != null) {
      for (var gateJson in json['gatesOnRoute']) {
        gates.add(RailwayGate.fromJson(gateJson));
      }
    }

    return GateRoute(
      id: json['id'] ?? '',
      startLocation: List<double>.from(json['startLocation'] ?? []),
      endLocation: List<double>.from(json['endLocation'] ?? []),
      polylinePoints: polylinePoints,
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 0,
      gatesOnRoute: gates,
      hasAlternateRoute: json['hasAlternateRoute'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'polylinePoints': polylinePoints,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'gatesOnRoute': gatesOnRoute.map((g) => g.toJson()).toList(),
      'hasAlternateRoute': hasAlternateRoute,
    };
  }

  GateRoute copyWith({
    String? id,
    List<double>? startLocation,
    List<double>? endLocation,
    List<List<double>>? polylinePoints,
    double? distanceKm,
    int? durationMinutes,
    List<RailwayGate>? gatesOnRoute,
    bool? hasAlternateRoute,
  }) {
    return GateRoute(
      id: id ?? this.id,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      gatesOnRoute: gatesOnRoute ?? this.gatesOnRoute,
      hasAlternateRoute: hasAlternateRoute ?? this.hasAlternateRoute,
    );
  }
}

/// User location model
class UserLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime? timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.timestamp,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
