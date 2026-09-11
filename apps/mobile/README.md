# Mobile

The Flutter client provides registration/login, secure refresh-token restoration, workspace switching, invitation acceptance, membership administration, workspace metrics, ontology-classified equipment and nested components, case creation/history, evidence selection/upload, the Phase 2 Knowledge Library, profile/logout, routing, theming, and API error/loading states.

For local web development with the Core API on port 8080:

```powershell
flutter pub get
flutter run -d chrome
```

Use `--dart-define=CORE_API_URL=http://<host>:8080/api/v1` when targeting a physical device or a non-default host.

For the standard Android emulator, the host computer is available as `10.0.2.2`:

```powershell
flutter run -d emulator-5554 --dart-define=CORE_API_URL=http://10.0.2.2:8080/api/v1
```
