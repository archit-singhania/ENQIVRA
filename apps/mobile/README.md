# ENQIVRA on macOS: iPhone Simulator and real iPhone

This guide runs the Flutter app on an iPhone Simulator or your own iPhone, with the local ENQIVRA APIs and data services running on your Mac. Android setup is not needed.

## What you need

- A Mac with Xcode installed and opened once.
- Flutter stable and Git.
- Maven and Python 3.12–3.14 for the local APIs. Docker Desktop is optional and adds the external database/vector/graph services.
- For a real iPhone: its cable, the device passcode, and an Apple ID signed into Xcode. A free Apple ID is enough to run a development build on your own phone.

Check the tools in Terminal:

```sh
flutter --version
git --version
python3 --version
mvn -version
xcodebuild -version
```

Docker is optional for the no-Docker backend setup. If you want the full local data services, install it from [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/), choosing the Apple silicon build for this Mac. Open Docker Desktop and wait until it says Docker is running. The first start may ask for your Mac password to install its networking helper.

In Xcode, open **Xcode → Settings → Components** and install the iOS Simulator runtime if it is not already listed as installed. Keep Xcode open until that download finishes; the runtime needs several gigabytes of free disk space. Then check:

```sh
xcrun simctl list devices available
flutter doctor -v
```

Warnings about Android or Chrome do not matter for this iPhone workflow. Xcode and the iOS Simulator runtime must be ready.

## 1. Start the local backend

The app stores accounts, equipment, and cases in the Core API and sends investigation, evidence, and knowledge requests to the Intelligence API. Both APIs must stay running while you use the app. The no-Docker setup below uses a persistent local H2 database for Core API data and SQLite for Intelligence API data. It is enough for the app walkthrough. The Intelligence API health page reports `degraded` while PostgreSQL, Qdrant, and Neo4j are absent; its `/ready` endpoint and local evidence, knowledge, investigation, and digital-twin routes still work.

First find your Mac's Wi-Fi IPv4 address in **System Settings → Wi-Fi → Details → IP address**, or run:

```sh
ipconfig getifaddr en0
```

Use that address in the commands below in place of `192.168.1.23`.

### Start the Core API

Open Terminal window 1:

```sh
cd ~/Documents/ENQIVRA/services/core-api
mvn -Dspring-boot.run.profiles=local '-Dspring-boot.run.arguments=--server.address=192.168.1.23' spring-boot:run
```

Wait until the log says `Started CoreApiApplication`. Leave this Terminal window open.

### Start the Intelligence API

Open Terminal window 2:

```sh
cd ~/Documents/ENQIVRA/services/intelligence-api
python3 -m venv .venv
.venv/bin/python -m pip install -e .
AUTH_REQUIRED=true \
ENFORCE_CORE_OWNERSHIP=true \
JWT_SECRET=local-development-secret-change-before-production \
CORE_API_URL=http://192.168.1.23:8080/api/v1 \
  .venv/bin/uvicorn enqivra.main:app --host 192.168.1.23 --port 8001
```

Python must be version 3.12, 3.13, or 3.14. On the first run, dependency installation takes a few minutes. Leave this Terminal window open too.

Open these links in Safari, replacing the example IP with your Mac's address:

- `http://192.168.1.23:8080/api/v1/health` — Core API should report `"status":"ok"`.
- `http://192.168.1.23:8001/api/v1/ready` — Intelligence API should report `"status":"ready"`.
- `http://192.168.1.23:8001/api/v1/health` — reports `degraded` without the optional Docker database services.
- `http://192.168.1.23:8001/docs` — Intelligence API reference.

This mode keeps data in `services/core-api/data` and `services/intelligence-api/data`. The `.gitignore` excludes both data folders.

### Optional: start all database services with Docker

For full PostgreSQL, Qdrant, Neo4j, and Valkey integration, install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/), open it, and wait until it says Docker is running. The first start may ask for your Mac password to install Docker's networking helper. Then use the repository root:

```sh
cd ~/Documents/ENQIVRA
cp .env.example .env
docker compose up --build -d
```

The first start downloads the service images and builds the two APIs. It can take several minutes and needs several gigabytes of free disk space. Check progress with:

```sh
docker compose ps
```

Wait until `postgres`, `core-api`, and `intelligence-api` say `healthy`; `neo4j` should also be healthy. Check the two API links in Safari:

- <http://localhost:8080/api/v1/health>
- <http://localhost:8000/api/v1/health>

The `8000/docs` page is the Intelligence API reference. Leave Docker Desktop open and the containers running. To stop them when you are done, run `docker compose down` from the repository folder. Your local data is preserved. Avoid `docker compose down -v`; `-v` deletes the saved test accounts and app data.

If a service does not become healthy, inspect its log:

```sh
docker compose logs --tail=100 core-api intelligence-api
```

## 2. Fetch Flutter packages

Open a second Terminal window:

```sh
cd ~/Documents/ENQIVRA/apps/mobile
flutter pub get
```

`flutter pub get` downloads the versions recorded by `pubspec.lock`. Keep that file in place so the app uses the project's known dependency versions.

This Mac has CocoaPods 1.16.2 under Ruby 3.2.0. In the same Terminal window, select that Ruby before any iOS/macOS `flutter run` command so Flutter can find CocoaPods:

```sh
export RBENV_VERSION=3.2.0
pod --version
```

The version should print `1.16.2`.

## 3. Run on an iPhone Simulator

Start an iPhone simulator from **Xcode → Open Developer Tool → Simulator**. In Simulator, use **File → Open Simulator** to pick an iPhone model. Or start one from Terminal after a runtime has been installed:

```sh
open -a Simulator
flutter devices
```

Copy the iPhone Simulator name or ID from `flutter devices`. The local APIs in this guide listen on the Mac's Wi-Fi IP, so pass that IP for both APIs when starting the app:

```sh
  flutter run -d <simulator-name-or-id> \
  --dart-define=CORE_API_URL=http://192.168.1.23:8080/api/v1 \
  --dart-define=INTELLIGENCE_API_URL=http://192.168.1.23:8001/api/v1
```

For example, if the listed device is `iPhone 17 Pro`, use:

```sh
flutter run -d 'iPhone 17 Pro' \
  --dart-define=CORE_API_URL=http://192.168.1.23:8080/api/v1 \
  --dart-define=INTELLIGENCE_API_URL=http://192.168.1.23:8001/api/v1
```

Replace the example IP in the command with your Mac's Wi-Fi IP. The first build takes longer while Flutter compiles the iOS app. After it opens, you can keep the Terminal session active and press `r` to hot-reload after code changes. Press `q` to stop the run.

## Optional: run the macOS desktop app

The project also has a generated macOS runner. This is a convenient way to inspect the whole Flutter UI on the Mac without the iOS Simulator runtime:

```sh
flutter run -d macos \
  --dart-define=CORE_API_URL=http://192.168.1.23:8080/api/v1 \
  --dart-define=INTELLIGENCE_API_URL=http://192.168.1.23:8001/api/v1
```

Replace the IP with your Mac's current Wi-Fi address. Camera and photo selection behave differently in the desktop app, so test those two permissions on iPhone.

## 4. Run on your real iPhone

1. Connect the iPhone to the Mac with its cable, unlock it, and tap **Trust** if asked. On the phone, turn on **Settings → Privacy & Security → Developer Mode** if iOS requests it, then restart the phone to enable Developer Mode.
2. Open Xcode and go to **Xcode → Settings → Accounts**. Add your Apple ID if it is not already there.
3. Open `apps/mobile/ios/Runner.xcworkspace` in Xcode. Select **Runner** in the project navigator, then select the **Runner** app target. Under **Signing & Capabilities**, turn on **Automatically manage signing** and choose your **Team**. If Xcode reports that the bundle identifier is already in use, change `ai.enqivra.enqivraMobile` to a unique value in the Runner target's **Signing & Capabilities** screen.
4. In Terminal, list connected devices:

   ```sh
   cd ~/Documents/ENQIVRA/apps/mobile
   flutter devices
   ```

5. Find the Mac's Wi-Fi IP address. In **System Settings → Wi-Fi → Details**, look for **IP address**, or try `ipconfig getifaddr en0` in Terminal. Both the iPhone and Mac must be on the same Wi-Fi network.
6. Start the app, replacing the example IP with the address from your Mac:

   ```sh
   flutter run -d <your-iphone-name-or-id> \
     --dart-define=CORE_API_URL=http://192.168.1.23:8080/api/v1 \
     --dart-define=INTELLIGENCE_API_URL=http://192.168.1.23:8001/api/v1
   ```

   Keep the iPhone unlocked while the first app install completes. On first use, allow local network, camera, and photo access when iOS asks. A free Apple signing profile can expire periodically; if Xcode reports a signing error later, repeat the signing step and run the command again.

The APIs bind to the Mac's Wi-Fi address in the no-Docker instructions, so use that same IP in the Dart defines for both Simulator and phone. On a real phone, `localhost` refers to the phone itself. If the phone cannot connect, first make sure each health link above opens on the Mac. Then check that Mac and phone use the same Wi-Fi and that macOS Firewall allows incoming connections for the API processes. These development endpoints use HTTP and are intended for a trusted local network only.

## What to expect in the app

The ENQIVRA logo animates briefly, then the welcome page appears. It has **Get started**, **I already have an account**, **About the author**, and a theme switch. After registration or sign-in, the home screen greets you by first name and shows shortcuts for diagnosing a problem, adding equipment, and opening the knowledge library.

Use new, throwaway test accounts and sample documents. Data is stored on your Mac and remains there after the app or backend is restarted.

## Manual test walkthrough

Follow these sections in order. Each step includes what to tap and what a working result looks like. The backend must be healthy for account, equipment, case, evidence, and knowledge flows. A physical phone also needs the Mac IP addresses above.

### A. Welcome, theme, registration, and sign-in

1. Launch ENQIVRA. Expect the animated logo and then the welcome page.
2. Tap the theme switch. Expect the colors to change; tap again to restore them.
3. Tap **About the author**. Expect the About page. Tap its back/home control to return.
4. Tap **Get started**. Enter a display name, a new test email address, an organization name, and a development-only password. Submit. Expect the home screen and your first name.
5. Open **Profile** and choose **Sign out**. Confirm the sign-out overlay. Expect to return to welcome.
6. Choose **I already have an account**, sign in with the new account, and expect to return home.
7. Sign out again and try one incorrect password. Expect an inline error; the screen should stay open so you can correct it.

### B. Equipment, label scan, components, and digital twin

1. Choose **Add equipment**. Enter a name and category; model and serial number are optional. Save. Expect the equipment list to show the new item.
2. Open the item. Expect its component area and digital-twin state.
3. Record a harmless sample reading such as `temperature`, `22`, `C`; add warning and critical thresholds if those fields are shown. Save and expect the reading/trend to refresh.
4. Choose **Add component**, enter a name and type, and save. Expect the component under the equipment.
5. Open **Scan equipment label**. Choose an existing photo; expect an analysis status/result. Then try taking a photo and allow Camera access. Expect the captured image to be analyzed. If you decline access, the app should remain usable; re-enable it in iPhone **Settings → Apps → ENQIVRA**.
6. Open the equipment actions menu and try each available case/evidence action. Expect each to open the related form or case flow.

### C. Diagnostic case, investigation, and evidence

1. From home, choose **Diagnose a problem**. Select the equipment, enter a short title and a clear symptom, and submit. Expect a case detail screen with safety status, evidence, investigation, possible causes, a next safe check, and repair guidance.
2. In Guided investigation, add an observation and submit it. Expect the investigation result to refresh. Cause probabilities become more useful as you add relevant evidence.
3. Add a small test image, audio recording, video, or telemetry CSV. Expect the evidence to appear in the case and an analysis result/status to be available. On iPhone, allow Photos or Camera when prompted. Use non-private samples.
4. Open the case history, leave the case, then reopen it. Expect the case and uploaded evidence to remain.

### D. Knowledge library and technical documents

1. Open **Knowledge library**. Expect a searchable list or an empty-state message.
2. Search for a word such as `compressor` or `temperature`. Expect matching entries/citations, or a clear no-results message if the local knowledge base has no match.
3. Open a result. Expect its detail and any relationships to be shown.
4. Choose **Add technical document**. Pick a small PDF, TXT, or Markdown sample, provide a title and domain, and upload. Expect an ingestion result.
5. Search for a distinctive phrase from that document. Expect a grounded result with a citation to the uploaded material.

### E. Profile, members, and workspaces

1. Open **Profile**. Check your name, role, workspace, theme, and About section.
2. Open **Organization members**. Expect the current member list and invitation controls.
3. Create an invitation for a second test email and note the displayed invitation code.
4. Sign out. Register a second throwaway account using that invited email. Open **Workspaces**, enter the invitation code, and join. Expect the invited organization to become available.
5. Return to the owner account and check the member list again. Only use test email addresses; invitations in this local app are for testing.

### F. Restart and persistence

1. Force-close ENQIVRA, then reopen it. Expect the saved session to return you to home.
2. Reopen the equipment, case, and knowledge entry. Expect saved server data to remain.
3. Sign out explicitly. Expect the welcome screen.

## Troubleshooting

- **`docker` command not found:** install and open Docker Desktop, then wait for its status to say Docker is running.
- **Containers keep starting or show unhealthy:** run `docker compose ps` and `docker compose logs --tail=100 core-api intelligence-api` from the repository folder. Without Docker, use the two local API commands above; the Intelligence health endpoint will report `degraded` because the optional graph/vector/database containers are not running.
- **Simulator not listed:** install an iOS Simulator runtime under **Xcode → Settings → Components**, open Simulator, then run `flutter devices` again.
- **iPhone not listed:** unlock it, trust the Mac, enable Developer Mode, reconnect the cable, and run `flutter devices` again.
- **Physical iPhone shows a connection error:** use the Mac's Wi-Fi IP, not `localhost`; verify the iPhone and Mac share Wi-Fi and both health links load on the Mac.
- **Build/signing error:** open `ios/Runner.xcworkspace`, select the Runner app target, set your Apple Development Team, then run the `flutter run` command again.
- **Camera/photo permission denied:** enable the relevant permission in iPhone Settings and reopen the scan flow.
- **Email already exists:** sign in with that test account or register with a different email. Data persists between runs. To erase all local test data, stop Docker and run `docker compose down -v` from the repository folder.
