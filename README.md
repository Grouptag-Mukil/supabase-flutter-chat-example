# Supabase Flutter Example App

This is an example Flutter app that demonstrates how to integrate Supabase into a Flutter project. Supabase is an open-source Firebase alternative that provides a suite of tools for building scalable and secure applications.

## Requirements

- Flutter version: 2.10.5
- Supabase Flutter version: 2.16.2

## Installation

1. Clone this repository to your local machine.
2. Open the project in your preferred Flutter IDE (e.g., Android Studio, VS Code).
3. Run the following command to install the dependencies:

   ```bash
   flutter pub get
   ```

4. Update the Supabase configuration in the `const/data.dart` file. Replace the following placeholders with your actual Supabase URL and API key:

   ```dart
   const URL = 'YOUR_SUPABASE_URL';
   const API = 'YOUR_SUPABASE_API_KEY';
   ```

5. Save the changes to `data.dart`.

## Usage

1. Build and run the Flutter app on a connected device or emulator using the following command:

   ```bash
   flutter run
   ```

2. The app *should* launch.
