# tricyclesystem

A Flutter app with Firebase Auth, Firestore, and role-based routing (student / driver / admin).

## Getting Started

- **iOS:** Ensure `ios/Runner/GoogleService-Info.plist` exists. Run `cd ios && pod install && cd ..`, then `flutter run`.
- **Android:** Ensure `android/app/google-services.json` exists and that your app’s SHA-1 is registered in Firebase (see below).

### Fixing Android "DEVELOPER_ERROR" or stuck loading

If the app stays on the loading screen or you see `DEVELOPER_ERROR` / `Phenotype.API is not available` in the Android emulator:

1. **Add your debug SHA-1 to Firebase**
   - Get your debug SHA-1:
     ```bash
     cd android && ./gradlew signingReport
     ```
   - In the report, copy the **SHA-1** under `Variant: debug` (e.g. `debug` or `release`).
   - In [Firebase Console](https://console.firebase.google.com/) → your project → Project settings (gear) → Your apps → select your Android app → Add fingerprint → paste the SHA-1 → Save.

2. **Update `google-services.json`**
   - In Firebase Console → Project settings → Your apps → download the new **google-services.json**.
   - Replace `android/app/google-services.json` with the downloaded file.

3. **Clean and run**
   ```bash
   flutter clean && flutter pub get && flutter run
   ```

If loading still fails (e.g. Firestore/network error), the app will sign you out and show the login screen. You can also tap **Sign out** on the loading screen to return to login.
