# TaskFlow — How to Run This Project

Project location: `C:\Users\Dell\taskflow`

This guide walks you through starting the backend API and the Flutter mobile app on Windows.

---

## Prerequisites

Before you start, make sure you have:

1. **Flutter SDK** installed (you already have Flutter 3.50+)
   - Check: open PowerShell and run:
     ```powershell
     flutter --version
     ```

2. **A device to run the app on** (pick one):
   - **Chrome** (easiest on Windows) — no extra setup
   - **Android emulator** — start an emulator from Android Studio first
   - **Windows desktop** — requires Visual Studio C++ toolchain (`flutter doctor` to check)

3. **Two terminal windows** — one for the backend, one for the Flutter app

---

## Step 1 — Start the Backend API

Open **PowerShell Terminal 1** and run these commands one by one:

```powershell
cd C:\Users\Dell\taskflow\backend
dart pub get
dart run bin/server.dart
```

**You should see:**

```
TaskFlow API running at http://localhost:3000
```

**Keep this terminal open** while you use the app. If you close it, the app cannot load tasks.

### Quick check (optional)

In a new PowerShell window:

```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/tasks"
```

You should see a JSON list of 15 tasks.

---

## Step 2 — Run the Flutter App

Open **PowerShell Terminal 2** and run:

```powershell
cd C:\Users\Dell\taskflow\mobile
flutter pub get
```

Then run the app on your preferred target:

### Option A — Chrome (recommended on Windows)

```powershell
flutter run -d chrome
```

### Option B — Edge browser

```powershell
flutter run -d edge
```

### Option C — Android emulator

1. Start an Android emulator from Android Studio (Device Manager).
2. Run:
   ```powershell
   flutter devices
   ```
   Confirm your emulator appears in the list.
3. Run:
   ```powershell
   flutter run
   ```
   The app uses `http://10.0.2.2:3000` automatically to reach the backend on your PC.

### Option D — Windows desktop

Only works if Visual Studio C++ tools are installed:

```powershell
flutter doctor
flutter run -d windows
```

If `flutter doctor` reports missing Visual Studio toolchain, use Chrome instead.

---

## Step 3 — Using the App

1. **Task list** — View tasks, filter by assignee (All / Aarav / Priya / Rohan) and status (All / Active / Completed).
2. **Tap a task** — Opens the detail screen.
3. **Checkbox** — Mark complete/incomplete from the list.
4. **FAB (+)** — Add a new task.
5. **Overdue** — Active tasks past their due date show a red **Overdue** badge. Tasks with no due date show **No due date**.

**Important:** Start the backend (Step 1) before opening the app, or you will see a connection error with a **Retry** button.

---

## Troubleshooting

### "Unable to connect to the server"

- Make sure Terminal 1 is still running `dart run bin/server.dart`.
- Confirm you see `TaskFlow API running at http://localhost:3000`.
- For Chrome/Windows: backend URL is `http://localhost:3000`.
- For Android emulator: the app uses `10.0.2.2` automatically — do not use `localhost` on the emulator.

### Backend port already in use

Another program may be using port 3000. Stop it or use a different port:

```powershell
$env:PORT = "3001"
dart run bin/server.dart
```

If you change the port, update `mobile/lib/config/api_config.dart` to match.

### Flutter dependencies out of date

```powershell
cd C:\Users\Dell\taskflow\mobile
flutter pub get
```

```powershell
cd C:\Users\Dell\taskflow\backend
dart pub get
```

### Run tests

```powershell
cd C:\Users\Dell\taskflow\mobile
flutter test
```

### Build web (static files, no live dev server)

```powershell
cd C:\Users\Dell\taskflow\mobile
flutter build web
```

Output: `mobile\build\web`

---

## Quick Reference — Copy & Paste

**Terminal 1 — Backend:**

```powershell
cd C:\Users\Dell\taskflow\backend
dart pub get
dart run bin/server.dart
```

**Terminal 2 — App (Chrome):**

```powershell
cd C:\Users\Dell\taskflow\mobile
flutter pub get
flutter run -d chrome
```

---

## Project folders

| Path | What it is |
|------|------------|
| `C:\Users\Dell\taskflow\backend` | REST API (Dart Shelf) |
| `C:\Users\Dell\taskflow\mobile` | Flutter app |
| `C:\Users\Dell\taskflow\README.md` | Full assessment documentation |

For assessment details (decisions, bug hunt, API docs), see `README.md` in the same folder.