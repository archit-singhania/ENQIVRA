# Mobile

The Flutter client provides registration/login, secure session and workspace workflows, ontology-classified equipment/components, cases and evidence, local knowledge ingestion, multimodal analysis, safety-triaged investigations, changing cause probabilities, next-best tests, ranked repair/replace guidance, and per-equipment digital twins with condition trends and predictive threshold warnings.

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
