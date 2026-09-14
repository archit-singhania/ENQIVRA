# Mobile

The Flutter client provides registration/login, secure refresh-token restoration, workspace switching, invitation acceptance, membership administration, workspace metrics, ontology-classified equipment and nested components, case creation/history, evidence selection/upload, the Knowledge Library, camera/gallery equipment-label analysis, local manual ingestion, and persistent safety-triaged investigations with grounded citations.

For local web development, start both the Core API on port 8080 and Intelligence API on port 8000, then run:

```powershell
flutter pub get
flutter run -d chrome --dart-define=CORE_API_URL=http://localhost:8080/api/v1 --dart-define=INTELLIGENCE_API_URL=http://localhost:8000/api/v1
```

Use both Dart defines with your computer's LAN IP when targeting a physical device.

For the standard Android emulator, the host computer is available as `10.0.2.2`:

```powershell
flutter run -d emulator-5554 --dart-define=CORE_API_URL=http://10.0.2.2:8080/api/v1 --dart-define=INTELLIGENCE_API_URL=http://10.0.2.2:8000/api/v1
```
