# MediaSaver Pro - Flutter App

MediaSaver Pro is a beautiful, robust Flutter mobile application to extract media details and download them locally seamlessly. 

It is built with a Feature-First Clean Architecture and uses Riverpod for State Management.

## Setup Instructions

1. **Install Platform Requirements**
   - Flutter SDK (latest stable)
   - Android Studio (for Emulator and SDK)
   - Xcode (for iOS scaffold, optional)
   
2. **Install Packages**
   ```bash
   flutter pub get
   ```

3. **Code Generation**
   To generate Hive serializers:
   ```bash
   dart run build_runner build -d
   ```

4. **Connect to Backend**
   Open `lib/core/network/api_client.dart` and ensure the `baseUrl` points to your backend:
   - For Android Emulators locally: `http://10.0.2.2:3000/api`
   - For Physical Devices: Use your machine's local IP (e.g., `http://192.168.1.x:3000/api`)
   - Ensure the `x-api-key` matches the backend `.env`.

5. **Run the Application**
   ```bash
   flutter run
   ```

## Architecture
This app enforces a strict clean architecture:

- **Core**: Contains themes, network interceptors, constants.
- **Features/Downloader**: Handles URL parsing, talking to the node backend, and starting platform-native background downloads using `flutter_downloader`.
- **Features/Gallery**: Manages downloaded items stored locally via `Hive DB`. View, play (via `chewie`), and `share_plus` integrations.
- **Features/Settings**: Contains Term/Disclaimer flows and basic app configurations.

## Permissions Required
- `INTERNET`: To contact the Node API and initiate video streams.
- `READ/WRITE_EXTERNAL_STORAGE`: To save decoded videos into the public file directory (Android <29) or Application Documents directory.
- `POST_NOTIFICATIONS`: To show the ongoing download track queue status.
