# MedApp Frontend - Medical Report Management Application

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-lightgrey)]()

> A comprehensive medical report management application built with Flutter, featuring AI-powered text recognition, digital signatures, voice-to-text capabilities, and advanced medical data management.

## 🌟 Key Features

### 🔬 Medical Intelligence
- **AI Text Recognition**: Google ML Kit integration for medical document scanning
- **Speech-to-Text**: Voice input for medical notes and reports
- **Language Detection & Translation**: Multi-language support for global healthcare
- **Digital Signatures**: Secure signature capture for medical documents
- **Document OCR**: Intelligent text extraction from medical images

### 📱 Cross-Platform Excellence
- **Universal Compatibility**: iOS, Android, Web, Windows, macOS, and Linux
- **Responsive Design**: Adaptive UI for all screen sizes and orientations
- **Offline-First**: Local data storage with Hive database
- **Real-time Sync**: Seamless data synchronization across devices
- **Progressive Web App**: Web-based access with native app features

### 🏥 Healthcare Management
- **Patient Records**: Comprehensive patient information management
- **Medical Reports**: Digital report creation, editing, and sharing
- **Appointment Scheduling**: Integrated calendar and notification system
- **Prescription Management**: Digital prescription handling
- **Healthcare Analytics**: Data visualization and insights

### 🛡️ Security & Compliance
- **Data Encryption**: Secure local and cloud data storage
- **HIPAA Compliance**: Healthcare data protection standards
- **Biometric Authentication**: Fingerprint and face recognition
- **Audit Trails**: Comprehensive activity logging
- **Secure Communications**: Encrypted data transmission

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK**: 3.0 or higher
- **Dart SDK**: 3.0 or higher
- **Android Studio**: For Android development
- **Xcode**: For iOS development (macOS only)
- **VS Code**: Recommended IDE with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/aliammari1/pulmocare-flutter-frontend.git
   cd pulmocare-flutter-frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Generate code (if needed)**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the application**
   ```bash
   # Development mode
   flutter run
   
   # Specific platform
   flutter run -d chrome        # Web
   flutter run -d android       # Android
   flutter run -d ios           # iOS
   flutter run -d windows       # Windows
   flutter run -d macos         # macOS
   flutter run -d linux         # Linux
   ```

## 📁 Project Architecture

```
lib/
├── config.dart                 # App configuration and constants
├── main.dart                   # Application entry point
├── models/                     # Data models and entities
│   ├── patient.dart           # Patient data model
│   ├── medical_report.dart    # Medical report model
│   └── appointment.dart       # Appointment model
├── navigation/                 # App navigation and routing
│   └── app_router.dart        # Route definitions
├── providers/                  # State management providers
│   ├── auth_provider.dart     # Authentication state
│   ├── patient_provider.dart  # Patient data management
│   └── theme_provider.dart    # UI theme management
├── screens/                    # UI screens and pages
│   ├── auth/                  # Authentication screens
│   ├── dashboard/             # Main dashboard
│   ├── patients/              # Patient management
│   ├── reports/               # Medical reports
│   └── settings/              # App settings
├── services/                   # Business logic and APIs
│   ├── api_service.dart       # REST API communication
│   ├── ml_service.dart        # ML Kit integration
│   ├── storage_service.dart   # Local data storage
│   └── notification_service.dart # Push notifications
├── state/                      # BLoC state management
│   ├── auth/                  # Authentication state
│   ├── patient/               # Patient state
│   └── report/                # Report state
├── theme/                      # UI theming and styling
│   ├── app_theme.dart         # Main theme configuration
│   ├── colors.dart            # Color palette
│   └── text_styles.dart       # Typography
├── utils/                      # Utility functions and helpers
│   ├── constants.dart         # App constants
│   ├── validators.dart        # Input validation
│   └── helpers.dart           # Common helper functions
└── widgets/                    # Reusable UI components
    ├── common/                # Common widgets
    ├── forms/                 # Form components
    └── charts/                # Data visualization
```

## 🏗️ Technology Stack

### Frontend Framework
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Material Design**: Google's design system
- **Cupertino**: iOS-style components

### State Management
- **Provider**: Lightweight state management
- **BLoC**: Business Logic Component pattern
- **Flutter Bloc**: Reactive state management

### Local Storage
- **Hive**: Fast, NoSQL database
- **Shared Preferences**: Simple key-value storage
- **Path Provider**: File system path access

### AI & ML Integration
- **Google ML Kit**: On-device machine learning
- **Text Recognition**: OCR capabilities
- **Language ID**: Language detection
- **Translation**: Multi-language support
- **Speech to Text**: Voice input processing

### Media & Documents
- **Image Picker**: Camera and gallery access
- **Signature**: Digital signature capture
- **PDF Generation**: Document creation
- **Printing**: Document printing support

### Networking & APIs
- **Dio**: HTTP client with interceptors
- **Connectivity Plus**: Network status monitoring
- **Pretty Dio Logger**: Request/response logging

### Maps & Location
- **Google Maps**: Interactive maps
- **Geolocator**: GPS positioning
- **Geocoding**: Address conversion

### Notifications & Communication
- **Local Notifications**: Push notifications
- **Email Sender**: Email integration
- **URL Launcher**: External links
- **Share Plus**: Content sharing

## 🧪 Testing Strategy

### Unit Testing
```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Widget Testing
```bash
# Test specific widgets
flutter test test/widgets/

# Integration testing
flutter test integration_test/
```

### Test Structure
```
test/
├── unit/                      # Unit tests
│   ├── models/               # Model tests
│   ├── services/             # Service tests
│   └── utils/                # Utility tests
├── widget/                    # Widget tests
│   ├── screens/              # Screen tests
│   └── widgets/              # Component tests
└── integration/               # Integration tests
    ├── auth_flow_test.dart   # Authentication flow
    └── patient_flow_test.dart # Patient management flow
```

## 📱 Platform-Specific Features

### iOS Features
- **HealthKit Integration**: Health data synchronization
- **Core ML**: On-device machine learning
- **Face ID/Touch ID**: Biometric authentication
- **Siri Shortcuts**: Voice commands
- **Apple Pencil**: Digital signature support

### Android Features
- **Health Connect**: Health data integration
- **ML Kit**: Google's ML services
- **Biometric Authentication**: Fingerprint/face unlock
- **Android Auto**: Car integration
- **Wear OS**: Smartwatch support

### Web Features
- **Progressive Web App**: Installable web application
- **Web Assembly**: High-performance computing
- **Camera API**: Web camera access
- **File System API**: File management
- **Push Notifications**: Web push notifications

### Desktop Features
- **Native File Dialogs**: System file pickers
- **System Tray**: Background operation
- **Window Management**: Multi-window support
- **Keyboard Shortcuts**: Desktop navigation
- **Print Support**: Native printing

## 🚀 Deployment Guide

### Mobile App Stores

#### Android - Google Play Store
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended)
flutter build appbundle --release

# Upload to Play Console
# Follow Google Play publishing guidelines
```

#### iOS - Apple App Store
```bash
# Build iOS release
flutter build ios --release

# Archive in Xcode
# Upload to App Store Connect
# Submit for review
```

### Web Deployment
```bash
# Build web release
flutter build web --release

# Deploy to hosting service
# Firebase Hosting, Netlify, Vercel, etc.
```

### Desktop Distribution
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🐳 Docker Support

### Development Environment
```dockerfile
# Dockerfile.dev
FROM cirrusci/flutter:stable

WORKDIR /app
COPY pubspec.yaml .
COPY pubspec.lock .
RUN flutter pub get

COPY . .
EXPOSE 8080

CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
```

### Production Build
```dockerfile
# Dockerfile
FROM nginx:alpine

COPY build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose
```yaml
version: '3.8'
services:
  pulmocare-flutter-frontend:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    volumes:
      - .:/app
      - /app/build
    environment:
      - FLUTTER_WEB_PORT=8080
```

## 🔧 Configuration

### Environment Variables (.env)
```env
# API Configuration
API_BASE_URL=https://api.medapp.com
API_VERSION=v1
API_TIMEOUT=30000

# Google Services
GOOGLE_MAPS_API_KEY=your_google_maps_key
GOOGLE_ML_KIT_API_KEY=your_ml_kit_key

# Firebase Configuration
FIREBASE_PROJECT_ID=medapp-project
FIREBASE_APP_ID=your_firebase_app_id

# Feature Flags
ENABLE_BIOMETRIC_AUTH=true
ENABLE_OFFLINE_MODE=true
ENABLE_PUSH_NOTIFICATIONS=true

# Development
DEBUG_MODE=false
LOG_LEVEL=info
```

### Theme Configuration
```dart
// lib/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    fontFamily: 'Poppins',
    // ... theme configuration
  );
  
  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    // ... dark theme configuration
  );
}
```

## 🤝 Contributing

We welcome contributions from the community! Please follow these guidelines:

### Development Workflow

1. **Fork the repository**
   ```bash
   git clone https://github.com/aliammari1/pulmocare-flutter-frontend.git
   cd pulmocare-flutter-frontend
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Set up development environment**
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```

4. **Make your changes**
   - Follow Flutter/Dart style guidelines
   - Add tests for new features
   - Update documentation
   - Run flutter analyze and fix any issues

5. **Commit your changes**
   ```bash
   git commit -m "feat: add amazing feature"
   ```

6. **Push and create PR**
   ```bash
   git push origin feature/amazing-feature
   ```

### Code Style Guidelines

#### Dart/Flutter Standards
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` for consistent formatting
- Run `flutter analyze` to catch potential issues
- Maintain 80%+ test coverage for new code

#### Naming Conventions
- **Files**: snake_case (e.g., `medical_report.dart`)
- **Classes**: PascalCase (e.g., `MedicalReport`)
- **Variables/Functions**: camelCase (e.g., `patientName`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `API_BASE_URL`)

#### Architecture Patterns
- Follow BLoC pattern for state management
- Use dependency injection with GetIt
- Implement repository pattern for data access
- Follow SOLID principles

## 📝 API Integration

### Authentication
```dart
// Login
POST /api/auth/login
{
  "email": "doctor@example.com",
  "password": "securepassword"
}

// Response
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "doctor@example.com",
    "role": "doctor"
  }
}
```

### Patient Management
```dart
// Get patients
GET /api/patients

// Create patient
POST /api/patients
{
  "name": "John Doe",
  "dateOfBirth": "1990-01-01",
  "phone": "+1234567890",
  "email": "john@example.com"
}

// Update patient
PUT /api/patients/{id}

// Delete patient
DELETE /api/patients/{id}
```

### Medical Reports
```dart
// Get reports
GET /api/reports?patientId={id}

// Create report
POST /api/reports
{
  "patientId": "patient_id",
  "type": "diagnosis",
  "content": "Medical report content",
  "attachments": ["file_url_1", "file_url_2"]
}
```

## 📊 Performance Optimization

### App Performance
- **Code Splitting**: Lazy loading of routes and features
- **Image Optimization**: Cached network images with compression
- **Memory Management**: Proper disposal of controllers and streams
- **Battery Optimization**: Efficient background task handling

### Bundle Size Optimization
```bash
# Analyze bundle size
flutter build apk --analyze-size
flutter build appbundle --analyze-size

# Tree shaking (automatically applied in release builds)
flutter build apk --release --tree-shake-icons
```

### Performance Monitoring
- **Firebase Performance**: Real-time performance monitoring
- **Crashlytics**: Crash reporting and analysis
- **Analytics**: User behavior tracking
- **Custom Metrics**: App-specific performance indicators

## 🔒 Security Best Practices

### Data Protection
- **Encryption**: All sensitive data encrypted at rest and in transit
- **Secure Storage**: Biometric authentication for data access
- **API Security**: JWT tokens with proper expiration
- **Input Validation**: Comprehensive input sanitization

### Privacy Compliance
- **HIPAA Compliance**: Healthcare data protection standards
- **GDPR Compliance**: European data protection regulations
- **Data Minimization**: Collect only necessary patient information
- **Audit Logging**: Complete activity trails

### Authentication & Authorization
```dart
// Biometric authentication
class BiometricAuth {
  static Future<bool> authenticate() async {
    final bool isAvailable = await LocalAuthentication().canCheckBiometrics;
    if (!isAvailable) return false;
    
    return await LocalAuthentication().authenticate(
      localizedReason: 'Authenticate to access medical data',
      biometricOnly: true,
    );
  }
}
```

## 📈 Analytics & Monitoring

### User Analytics
- **Screen Views**: Track user navigation patterns
- **Feature Usage**: Monitor feature adoption rates
- **Performance Metrics**: App loading times and crashes
- **User Engagement**: Session duration and retention

### Medical Analytics
- **Report Generation**: Automated medical insights
- **Patient Trends**: Health pattern analysis
- **Treatment Efficacy**: Outcome tracking
- **Compliance Monitoring**: Medication adherence

## 🗺️ Roadmap

### Version 2.0 (Q2 2024)
- [ ] Advanced AI diagnostics integration
- [ ] Telemedicine video consultation
- [ ] Wearable device connectivity
- [ ] Advanced analytics dashboard
- [ ] Multi-tenant support

### Version 3.0 (Q4 2024)
- [ ] Blockchain health records
- [ ] AR/VR medical visualization
- [ ] IoT medical device integration
- [ ] Predictive health analytics
- [ ] Global healthcare network

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Ali Ammari

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👤 Author

**Ali Ammari**
- GitHub: [@aliammari1](https://github.com/aliammari1)
- LinkedIn: [Ali Ammari](https://linkedin.com/in/ali-ammari)
- Email: [contact@aliammari.com](mailto:contact@aliammari.com)
- Portfolio: [aliammari.com](https://aliammari.com)

## 🙏 Acknowledgments

- **Flutter Team** for the incredible cross-platform framework
- **Google ML Kit** for powerful on-device machine learning
- **Open Source Community** for amazing packages and contributions
- **Healthcare Professionals** for domain expertise and feedback
- **Beta Testers** for valuable testing and feedback

## 🔗 Related Projects

- [medapp-backend](https://github.com/aliammari1/medapp-backend) - Backend API service

## 📞 Support & Contact

- **Documentation**: [Project Wiki](https://github.com/aliammari1/pulmocare-flutter-frontend/wiki)
- **Issues**: [GitHub Issues](https://github.com/aliammari1/pulmocare-flutter-frontend/issues)
- **Discussions**: [GitHub Discussions](https://github.com/aliammari1/pulmocare-flutter-frontend/discussions)
- **Email Support**: [contact@aliammari.com](mailto:contact@aliammari.com)

---

<div align="center">
  <p>
    <strong>🏥 Building the future of digital healthcare 🏥</strong>
  </p>
  <p>
    <strong>⭐ Star this repository if you find it helpful!</strong>
  </p>
  <p>
    Made with ❤️ by <a href="https://github.com/aliammari1">Ali Ammari</a>
  </p>
</div>
