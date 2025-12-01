# 🌤️ Weather App - Real-Time Weather Application

A modern, feature-rich Flutter weather application that provides real-time weather information with a beautiful and intuitive user interface. Built with clean architecture principles and optimized for performance.

---

## 📱 About the Project

**Weather App** is a cross-platform mobile application that allows users to search for weather conditions in cities worldwide, save favorite locations, and switch between light and dark themes. The app features robust error handling, offline caching, and a smooth, responsive user experience.

### 🎯 Key Features

- **Real-Time Weather Data**: Get current weather conditions for any city worldwide
- **Smart Search**: Intelligent city search with error handling for misspelled entries
- **Favorites Management**: Save up to 10 favorite cities for quick access
- **Location-Based Weather**: Automatic weather detection based on device location
- **Theme Switching**: Seamless light/dark mode toggle with persistent preferences
- **Offline Caching**: Access recently viewed weather data without internet connection
- **User Authentication**: Secure login and signup with local data persistence
- **Responsive Design**: Beautiful UI optimized for different screen sizes
- **Error Recovery**: Graceful error handling with user-friendly messages

---
## 📱 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/af692dbc-259e-444e-9b30-8b945f24d0ed" width="230">
  <img src="https://github.com/user-attachments/assets/e0a52f5b-fe35-4e15-989d-d4c06c3aeacb" width="230">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/415bfc6a-e7b0-4d4e-b1c2-dbd6a91aba4a" width="230">
  <img src="https://github.com/user-attachments/assets/ced8ee77-40fa-447d-8a30-a756fb48150f" width="230">
</p>


## 🛠️ Technologies & Tools

### **Framework & Language**
- **Flutter** 3.x - Google's UI toolkit for building natively compiled applications
- **Dart** 2.19+ - Client-optimized programming language

### **State Management**
- **Provider** - Simple and scalable state management solution
- **ChangeNotifier** - Reactive state updates across the application

### **Local Database & Persistence**
- **Hive** - Lightweight and blazing-fast NoSQL database for Flutter
- **SharedPreferences** - Key-value storage for simple data persistence

### **HTTP & Networking**
- **http** package - HTTP client for API requests
- **dart:convert** - JSON encoding and decoding

### **Data Serialization**
- **json_serializable** - Automatic JSON serialization and deserialization
- **build_runner** - Code generation tool for Dart

### **Location Services**
- **Geolocator** - Access to location services and GPS

### **UI/UX Libraries**
- **Material Design** - Google's design system for beautiful UIs
- **Custom Themes** - Dynamic theming with AppTheme configurations

---

## 🌐 External Services & APIs

### **WeatherAPI**
- **Provider**: [WeatherAPI.com](https://www.weatherapi.com/)
- **Endpoint**: `http://api.weatherapi.com/v1/current.json`
- **Features Used**:
  - Current weather conditions
  - City-based search
  - Coordinate-based search (latitude/longitude)
  - Temperature, humidity, wind speed, conditions
- **Cache Duration**: 10 minutes per city
- **Rate Limiting**: Handled with timeout and retry logic

---

## 📁 Project Structure

<img width="726" height="696" alt="image" src="https://github.com/user-attachments/assets/eadc9b68-6079-4194-a744-e837a1da2894" />


---

## 🚀 Getting Started

### **Prerequisites**

- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version 2.19.0 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **iOS Simulator** (Mac only) or **Android Emulator**

### **Installation**

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/yourusername/weather-app.git
   cd weather-app
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **Generate model files**
   \`\`\`bash
   flutter pub run build_runner build --delete-conflicting-outputs
   \`\`\`

4. **Run the application**
   \`\`\`bash
   flutter run
   \`\`\`

### **API Configuration**

The app uses WeatherAPI with a built-in API key. For production use, replace the API key in:

**`lib/services/weather_service.dart`**
\`\`\`dart
static const String _apiKey = 'YOUR_API_KEY_HERE';
\`\`\`

Get your free API key at [WeatherAPI.com](https://www.weatherapi.com/)

---

## 💡 Core Functionality

### **Authentication System**
- Local user registration and login
- Email validation with regex patterns
- Password strength requirements (min 6 characters, letters + numbers)
- Secure password storage with Hive encryption
- Persistent login sessions

### **Weather Features**
- **Search by City**: Type any city name to get weather data
- **GPS Location**: Automatic detection of current location weather
- **Favorites**: Quick access to frequently checked cities (max 10)
- **Real-time Updates**: Pull-to-refresh for latest data
- **Offline Mode**: Cache displays last fetched data

### **Performance Optimizations**
- **HTTP Client Reuse**: Single persistent client for all requests
- **Request Deduplication**: Prevents multiple simultaneous calls for same city
- **Smart Caching**: 10-minute cache with automatic cleanup
- **Lazy Loading**: Efficient widget rebuilding with const constructors
- **Null Safety**: Comprehensive null checks prevent crashes

### **Error Handling**
- Network timeout recovery
- Invalid city name suggestions
- API rate limit handling
- JSON parsing error recovery
- User-friendly error messages

---

## 🎨 UI/UX Features

### **Theme System**
- **Light Mode**: Clean, bright interface for daytime use
- **Dark Mode**: Eye-friendly dark theme for night usage
- **Persistent Selection**: Theme preference saved locally

### **Design Highlights**
- Material Design 3 guidelines
- Smooth animations and transitions
- Loading states with progress indicators
- Error states with retry actions
- Empty states with helpful messages
- Responsive layouts for all screen sizes

---

## 📊 Code Architecture

### **Design Patterns**
- **Provider Pattern**: Centralized state management
- **Service Layer**: Separation of business logic from UI
- **Repository Pattern**: Data access abstraction
- **Singleton**: Single HTTP client instance

### **Code Quality**
- **Clean Code**: Descriptive variable and function names
- **Comprehensive Comments**: Detailed inline documentation in French
- **Error Boundaries**: Try-catch blocks throughout
- **Type Safety**: Full Dart null-safety compliance
- **Separation of Concerns**: Clear division between UI, logic, and data

---

## 🔒 Security Features

- Email normalization (lowercase)
- Password validation requirements
- Secure local storage with Hive
- No sensitive data in logs
- API key protection (should use env variables in production)

---

## 🧪 Testing Recommendations

For production deployment, implement:

- **Unit Tests**: Service and provider logic
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user flows
- **API Mocking**: Test without live API calls

---

## 📈 Future Enhancements

- [ ] 7-day weather forecast
- [ ] Hourly weather predictions
- [ ] Weather alerts and notifications
- [ ] Multiple language support (i18n)
- [ ] Weather widgets for home screen
- [ ] Social sharing of weather conditions
- [ ] Historical weather data
- [ ] Weather maps and radar

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---


---



## 🙏 Acknowledgments

- [WeatherAPI.com](https://www.weatherapi.com/) for providing free weather data

---




---

