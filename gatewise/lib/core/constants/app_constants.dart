/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GateWise';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (placeholder - configure for production)
  static const String baseUrl = 'https://api.gatewise.com';
  static const String gatesEndpoint = '/gates';
  static const String statusEndpoint = '/status';
  static const String routesEndpoint = '/routes';
  
  // Map Settings
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;
  
  // Location Settings
  static const double locationUpdateInterval = 5000; // ms
  static const double locationFastestInterval = 2000; // ms
  
  // Gate Status
  static const int statusOpenValue = 1;
  static const int statusClosedValue = 0;
  static const int statusLikelyToCloseValue = 2;
  
  // Time thresholds
  static const int gateClosureWarningTime = 5; // minutes before reaching gate
  static const int alternateRouteThreshold = 10; // suggest alternate if wait > 10 min
  
  // Cache durations
  static const int gateStatusCacheDuration = 60; // seconds
  static const int routeCacheDuration = 300; // seconds
  
  // UI Constants
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 8.0;
  static const double bottomSheetRadius = 24.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Animation durations
  static const int animationDurationShort = 200; // ms
  static const int animationDurationMedium = 300; // ms
  static const int animationDurationLong = 500; // ms
}
