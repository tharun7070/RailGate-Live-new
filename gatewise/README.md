# GateWise - Smart Railway Gate Status & Route Decision App

An industry-level Flutter application that helps commuters avoid unnecessary waiting at railway level crossings by showing real-time gate status and suggesting smarter routes.

## Features

### Core Functionality
- **Live Gate Status**: Real-time display of railway gate status (Open/Closed/Likely to Close)
- **Map-Based Visualization**: Interactive map showing all railway gates with color-coded markers
- **Route Awareness**: Detects gates on your selected route before you reach them
- **Advance Alerts**: Warns users about closed gates ahead
- **Alternate Route Suggestions**: Suggests alternative routes when waiting time is high
- **Crowd-Sourced Updates**: Users can report current gate status to help others

### UI/UX Features
- Clean, professional interface inspired by "Where is My Train" app
- White and Sky Blue color theme
- Full Dark Mode support
- Smooth animations and transitions
- Bottom sheet dialogs for detailed information
- Pull-to-refresh functionality
- Loading states and error handling

## Project Structure

```
gatewise/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart      # Color palette definitions
│   │   │   └── app_constants.dart   # App-wide constants
│   │   ├── theme/
│   │   │   ├── app_theme.dart       # Light theme configuration
│   │   │   └── app_theme_dark.dart  # Dark theme configuration
│   │   └── widgets/
│   │       └── common_widgets.dart  # Reusable UI components
│   ├── data/
│   │   ├── models/
│   │   │   └── models.dart          # Data models (Gate, Route, Location)
│   │   └── repositories/
│   │       └── repositories.dart    # Data repositories (Mock implementations)
│   ├── features/
│   │   └── home/
│   │       ├── providers/
│   │       │   └── home_providers.dart  # State management providers
│   │       └── screens/
│   │           └── home_screen.dart     # Main screens (Map, List, Settings)
│   └── presentation/
│       └── screens/                 # Additional presentation screens
├── assets/
│   ├── images/                      # Image assets
│   └── icons/                       # Icon assets
├── test/                            # Unit and widget tests
├── pubspec.yaml                     # Dependencies
└── analysis_options.yaml            # Linter rules
```

## Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile framework
- **Material Design 3**: Modern UI components
- **Provider**: State management

### Backend (Planned)
- **Firebase/Supabase**: Real-time database
- **Google Maps API**: Maps and directions
- **REST API**: Custom backend services

### Key Dependencies
- `provider`: State management
- `google_maps_flutter`: Map integration
- `location`: User location tracking
- `geolocator`: Geolocation services
- `http`/`dio`: HTTP client
- `shared_preferences`: Local storage
- `hive`: NoSQL local database

## Getting Started

### Prerequisites
- Flutter SDK (>=3.5.0)
- Dart SDK (>=3.5.0)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd gatewise
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Google Maps API key (for production):
   - Create `android/app/src/main/res/values/strings.xml`
   - Add: `<string name="google_maps_key">YOUR_API_KEY</string>`

4. Run the app:
```bash
flutter run
```

## Configuration

### Google Maps Setup
1. Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Maps SDK for Android/iOS
3. Add the key to your platform-specific configuration files

### Environment Variables
Create a `.env` file for sensitive configuration:
```
GOOGLE_MAPS_API_KEY=your_api_key_here
API_BASE_URL=https://api.gatewise.com
```

## Architecture

The app follows a clean architecture pattern:

1. **Presentation Layer**: UI components and screens
2. **Business Logic Layer**: Providers and state management
3. **Data Layer**: Models, repositories, and services

### State Management
- Uses Provider pattern for state management
- Separate providers for gates, routes, theme, and location
- Reactive updates with ChangeNotifier

### Theme System
- Light theme: White background with sky blue accents
- Dark theme: Dark background with adjusted sky blue accents
- Toggle available in Settings screen
- Persists user preference

## Screens

### Home Screen (Tab Navigation)
1. **Map Tab**: Interactive map view with gate markers
2. **Gates Tab**: List view of all gates with status
3. **Settings Tab**: App settings and preferences

### Key Components
- **StatusIndicator**: Color-coded status display
- **GateInfoCard**: Gate information card
- **RouteSummaryCard**: Route details with gate warnings
- **RouteSearchSheet**: Destination search bottom sheet
- **GateDetailsSheet**: Detailed gate information
- **ReportStatusSheet**: User status reporting

## Color Palette

### Primary Colors
- Sky Blue: `#00B4D8`
- Light Sky Blue: `#48CAE4`
- Dark Sky Blue: `#0077B6`
- Accent Sky Blue: `#90E0EF`

### Status Colors
- Open: `#2ECC71` (Green)
- Closed: `#E74C3C` (Red)
- Likely to Close: `#F39C12` (Orange)
- Unknown: `#95A5A6` (Gray)

## Future Enhancements

- [ ] Real Google Maps integration
- [ ] Live train tracking for gate closure prediction
- [ ] Push notifications for gate status changes
- [ ] IoT sensor integration at gates
- [ ] Historical data and analytics
- [ ] Multiple city support
- [ ] Voice navigation integration
- [ ] Offline mode support
- [ ] User authentication and profiles
- [ ] Gamification for crowd-sourced updates

## Testing

Run tests with:
```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Performance Considerations

- Lazy loading of gate data
- Efficient list rendering with ListView.builder
- Optimized state updates
- Minimal rebuilds with const constructors
- Cached network responses

## Security

- API key protection via environment variables
- Secure storage for sensitive data
- Input validation
- Rate limiting for user reports

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is created for academic and experimental purposes.  
All trademarks and map data belong to their respective owners.

## Author

**Lord Sir Tharun**  
Student Developer | Problem Solver | Smart Mobility Enthusiast

## Support

For issues and questions, please open an issue on the repository.

---

*Don't wait at the gate. Decide before you reach it.*
