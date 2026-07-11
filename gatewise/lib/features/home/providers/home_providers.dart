import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/constants/app_colors.dart';

/// Provider for managing gate status state
class GateProvider with ChangeNotifier {
  final GateRepository _gateRepository;
  
  List<RailwayGate> _gates = [];
  RailwayGate? _selectedGate;
  bool _isLoading = false;
  String? _error;

  GateProvider({GateRepository? gateRepository})
      : _gateRepository = gateRepository ?? MockGateRepository();

  List<RailwayGate> get gates => _gates;
  RailwayGate? get selectedGate => _selectedGate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<RailwayGate> get openGates => 
      _gates.where((g) => g.status == GateStatus.open).toList();
  
  List<RailwayGate> get closedGates => 
      _gates.where((g) => g.status == GateStatus.closed).toList();
  
  List<RailwayGate> get likelyToCloseGates => 
      _gates.where((g) => g.status == GateStatus.likelyToClose).toList();

  Future<void> loadGates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gates = await _gateRepository.getAllGates();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    
    notifyListeners();
  }

  Future<void> loadNearbyGates(double latitude, double longitude) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gates = await _gateRepository.getGatesNearby(latitude, longitude);
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    
    notifyListeners();
  }

  void selectGate(RailwayGate gate) {
    _selectedGate = gate;
    notifyListeners();
  }

  void clearSelectedGate() {
    _selectedGate = null;
    notifyListeners();
  }

  Future<void> reportGateStatus(String gateId, GateStatus status) async {
    try {
      await _gateRepository.updateGateStatus(gateId, status);
      // Update local state
      final index = _gates.indexWhere((g) => g.id == gateId);
      if (index != -1) {
        _gates[index] = _gates[index].copyWith(
          status: status,
          lastUpdated: DateTime.now(),
        );
        if (_selectedGate?.id == gateId) {
          _selectedGate = _gates[index];
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  RailwayGate? getGateById(String id) {
    try {
      return _gates.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Provider for managing route state
class RouteProvider with ChangeNotifier {
  final RouteRepository _routeRepository;
  
  GateRoute? _currentRoute;
  List<GateRoute> _alternateRoutes = [];
  bool _isLoading = false;
  String? _error;

  RouteProvider({RouteRepository? routeRepository})
      : _routeRepository = routeRepository ?? MockRouteRepository();

  GateRoute? get currentRoute => _currentRoute;
  List<GateRoute> get alternateRoutes => _alternateRoutes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool get hasClosedGatesOnRoute => 
      _currentRoute?.gatesOnRoute.any((g) => g.status == GateStatus.closed) ?? false;
  
  bool get hasAlternateRoute => _alternateRoutes.isNotEmpty;

  Future<void> findRoute({
    required List<double> startLocation,
    required List<double> endLocation,
  }) async {
    _isLoading = true;
    _error = null;
    _alternateRoutes = [];
    notifyListeners();

    try {
      _currentRoute = await _routeRepository.getRoute(
        startLocation: startLocation,
        endLocation: endLocation,
      );
      
      // If there are closed gates, fetch alternate routes
      if (_currentRoute?.hasAlternateRoute == true) {
        _alternateRoutes = await _routeRepository.getAlternateRoutes(
          startLocation: startLocation,
          endLocation: endLocation,
        );
      }
      
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    
    notifyListeners();
  }

  void selectRoute(GateRoute route) {
    _currentRoute = route;
    notifyListeners();
  }

  void clearRoute() {
    _currentRoute = null;
    _alternateRoutes = [];
    notifyListeners();
  }
}

/// Provider for managing theme state
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

/// Provider for managing user location
class LocationProvider with ChangeNotifier {
  UserLocation? _currentLocation;
  bool _isLoading = false;
  String? _error;
  bool _permissionGranted = false;

  UserLocation? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get permissionGranted => _permissionGranted;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In production, use actual location service
      // For now, use mock location (Mumbai coordinates)
      await Future.delayed(const Duration(milliseconds: 500));
      
      _currentLocation = const UserLocation(
        latitude: 19.0760,
        longitude: 72.8777,
        accuracy: 10.0,
        timestamp: null,
      );
      _permissionGranted = true;
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _permissionGranted = false;
    }
    
    notifyListeners();
  }

  void updateLocation(double latitude, double longitude) {
    _currentLocation = UserLocation(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }
}
