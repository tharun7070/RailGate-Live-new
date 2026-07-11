import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Abstract repository for gate operations
abstract class GateRepository {
  Future<List<RailwayGate>> getAllGates();
  Future<RailwayGate?> getGateById(String id);
  Future<List<RailwayGate>> getGatesNearby(double latitude, double longitude, {double radiusKm = 5.0});
  Future<void> updateGateStatus(String gateId, GateStatus status, {String? userId});
  Stream<List<RailwayGate>> watchGates();
}

/// Abstract repository for route operations
abstract class RouteRepository {
  Future<GateRoute?> getRoute({
    required List<double> startLocation,
    required List<double> endLocation,
  });
  
  Future<List<GateRoute>> getAlternateRoutes({
    required List<double> startLocation,
    required List<double> endLocation,
  });
  
  Future<bool> isGateOnRoute({
    required String gateId,
    required List<List<double>> polylinePoints,
  });
}

/// Mock implementation of GateRepository for development
class MockGateRepository implements GateRepository {
  // Sample gates data
  final List<RailwayGate> _sampleGates = [
    const RailwayGate(
      id: 'gate_1',
      name: 'Station Road Crossing',
      latitude: 19.0760,
      longitude: 72.8777,
      status: GateStatus.open,
      estimatedWaitTime: 0,
      description: 'Main railway crossing near central station',
    ),
    const RailwayGate(
      id: 'gate_2',
      name: 'Market Street Gate',
      latitude: 19.0896,
      longitude: 72.8656,
      status: GateStatus.closed,
      estimatedWaitTime: 8,
      description: 'Busy market area crossing',
    ),
    const RailwayGate(
      id: 'gate_3',
      name: 'Highway Level Crossing',
      latitude: 19.0544,
      longitude: 72.8905,
      status: GateStatus.likelyToClose,
      estimatedWaitTime: 3,
      description: 'Major highway intersection',
    ),
    const RailwayGate(
      id: 'gate_4',
      name: 'School Zone Crossing',
      latitude: 19.0728,
      longitude: 72.8826,
      status: GateStatus.open,
      estimatedWaitTime: 0,
      description: 'Near educational institutions',
    ),
    const RailwayGate(
      id: 'gate_5',
      name: 'Industrial Area Gate',
      latitude: 19.0625,
      longitude: 72.8714,
      status: GateStatus.open,
      estimatedWaitTime: 0,
      description: 'Industrial zone crossing',
    ),
  ];

  @override
  Future<List<RailwayGate>> getAllGates() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _sampleGates;
  }

  @override
  Future<RailwayGate?> getGateById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _sampleGates.firstWhere((gate) => gate.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<RailwayGate>> getGatesNearby(double latitude, double longitude, {double radiusKm = 5.0}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Simple distance calculation (Haversine formula simplified)
    return _sampleGates.where((gate) {
      final double latDiff = (gate.latitude - latitude).abs();
      final double lngDiff = (gate.longitude - longitude).abs();
      // Rough approximation: 1 degree ≈ 111 km
      final double distance = latDiff * 111.0;
      return distance <= radiusKm;
    }).toList();
  }

  @override
  Future<void> updateGateStatus(String gateId, GateStatus status, {String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (kDebugMode) {
      print('Gate $gateId status updated to $status by user $userId');
    }
  }

  @override
  Stream<List<RailwayGate>> watchGates() {
    // In a real implementation, this would listen to Firestore or other real-time database
    return Stream.periodic(const Duration(seconds: 30), (_) => _sampleGates);
  }
}

/// Mock implementation of RouteRepository for development
class MockRouteRepository implements RouteRepository {
  @override
  Future<GateRoute?> getRoute({
    required List<double> startLocation,
    required List<double> endLocation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Generate sample polyline points (in real app, use Google Maps Directions API)
    final List<List<double>> polylinePoints = _generatePolyline(startLocation, endLocation);
    
    // Check which gates are on this route (simplified logic)
    final List<RailwayGate> gatesOnRoute = [];
    for (final point in polylinePoints) {
      for (final gate in MockGateRepository()._sampleGates) {
        final double latDiff = (gate.latitude - point[0]).abs();
        final double lngDiff = (gate.longitude - point[1]).abs();
        if (latDiff < 0.01 && lngDiff < 0.01) {
          if (!gatesOnRoute.any((g) => g.id == gate.id)) {
            gatesOnRoute.add(gate.copyWith(isOnRoute: true));
          }
        }
      }
    }
    
    return GateRoute(
      id: 'route_${DateTime.now().millisecondsSinceEpoch}',
      startLocation: startLocation,
      endLocation: endLocation,
      polylinePoints: polylinePoints,
      distanceKm: _calculateDistance(startLocation, endLocation),
      durationMinutes: ((_calculateDistance(startLocation, endLocation) / 40) * 60).ceil(),
      gatesOnRoute: gatesOnRoute,
      hasAlternateRoute: gatesOnRoute.any((g) => g.status == GateStatus.closed),
    );
  }

  @override
  Future<List<GateRoute>> getAlternateRoutes({
    required List<double> startLocation,
    required List<double> endLocation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    // Generate 1-2 alternate routes
    final List<GateRoute> alternates = [];
    final int numAlternates = 1 + (DateTime.now().millisecond % 2);
    
    for (int i = 0; i < numAlternates; i++) {
      final List<List<double>> polylinePoints = _generateAlternatePolyline(
        startLocation, 
        endLocation, 
        offset: (i + 1) * 0.02,
      );
      
      alternates.add(GateRoute(
        id: 'alternate_${i}_${DateTime.now().millisecondsSinceEpoch}',
        startLocation: startLocation,
        endLocation: endLocation,
        polylinePoints: polylinePoints,
        distanceKm: _calculateDistance(startLocation, endLocation) * (1.1 + (i * 0.05)),
        durationMinutes: ((_calculateDistance(startLocation, endLocation) / 40) * 60 * (1.1 + (i * 0.05))).ceil(),
        gatesOnRoute: [], // Alternate routes typically avoid closed gates
        hasAlternateRoute: false,
      ));
    }
    
    return alternates;
  }

  @override
  Future<bool> isGateOnRoute({
    required String gateId,
    required List<List<double>> polylinePoints,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final mockRepo = MockGateRepository();
    final gate = await mockRepo.getGateById(gateId);
    if (gate == null) return false;
    
    for (final point in polylinePoints) {
      final double latDiff = (gate.latitude - point[0]).abs();
      final double lngDiff = (gate.longitude - point[1]).abs();
      if (latDiff < 0.005 && lngDiff < 0.005) {
        return true;
      }
    }
    
    return false;
  }

  List<List<double>> _generatePolyline(List<double> start, List<double> end) {
    final List<List<double>> points = [];
    final int steps = 20;
    
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      points.add([
        start[0] + (end[0] - start[0]) * t,
        start[1] + (end[1] - start[1]) * t,
      ]);
    }
    
    return points;
  }

  List<List<double>> _generateAlternatePolyline(
    List<double> start, 
    List<double> end, {
    required double offset,
  }) {
    final List<List<double>> points = [];
    final int steps = 20;
    
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      // Add a curve to the route
      final double curve = offset * sin(t * 3.14159);
      points.add([
        start[0] + (end[0] - start[0]) * t + curve,
        start[1] + (end[1] - start[1]) * t,
      ]);
    }
    
    return points;
  }

  double _calculateDistance(List<double> start, List<double> end) {
    // Haversine formula
    const double earthRadius = 6371; // km
    final double lat1 = start[0] * 3.14159 / 180;
    final double lat2 = end[0] * 3.14159 / 180;
    final double dLat = (end[0] - start[0]) * 3.14159 / 180;
    final double dLng = (end[1] - start[1]) * 3.14159 / 180;
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
                     cos(lat1) * cos(lat2) *
                     sin(dLng / 2) * sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
}
