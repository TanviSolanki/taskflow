# TaskFlow

A minimal two-screen task manager built for the EnvisionStudio Mobile App Developer practical assessment.

## 1. How to Run Locally

**Technology stack:** Flutter (mobile UI) + Dart Shelf (REST API backend). Both run with the Dart/Flutter SDK already on your machine — no Node.js required.

### Prerequisites

- Flutter SDK 3.x (includes Dart 3.x)
- A device or emulator (Android/iOS) or Windows desktop

### Step 1 — Start the backend

```bash
cd backend
dart pub get
dart run bin/server.dart
```

The API starts at `http://localhost:3000`.

### Step 2 — Run the Flutter app

Open a second terminal:

```bash
cd mobile
flutter pub get
flutter run
```

- **Windows desktop:** `flutter run -d windows`
- **Chrome (web):** `flutter run -d chrome`
- **Android emulator:** use `10.0.2.2:3000` (configured automatically in `lib/config/api_config.dart`)

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT`   | `3000`  | Backend listen port |

### API endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | `/api/tasks?assignee=&status=` | List tasks with optional filters |
| POST   | `/api/tasks` | Create a task (returns 400 on validation error) |
| PATCH  | `/api/tasks/:id/toggle` | Toggle completion status |

### Overdue behaviour

Tasks with `dueDate: null` show **"No due date"** and are never marked overdue. Completed tasks are **never** shown as overdue, even if their due date is in the past — only active (incomplete) tasks past their due date display the red overdue badge.

## 2. Screen Structure

```
Task List → Task Detail → Back to Task List
Task List → Add Task (form) → Back to Task List
```

## 3. Decision 1 — Optimistic vs. Pessimistic

**Chosen approach: Optimistic.** The UI updates the checkbox immediately when marking complete/incomplete, then rolls back if the server request fails — this gives instant tactile feedback on mobile while keeping data consistent when the network is unreliable.

## 4. Decision 2 — Filter Persistence

**Chosen behaviour: Filters persist.** Assignee and status filters live in a `TaskProvider` at the app root, so navigating to task detail or add-task and returning keeps the same filter selection without extra state passing.

## 5. Bug Hunt

**Bug 1 — Timezone:** `new Date().toISOString().split('T')[0]` produces today's date in **UTC**, not the user's local timezone, so near midnight the comparison can mark tasks overdue (or not overdue) incorrectly compared to local calendar dates.

**Bug 2 — Missing/null dueDate:** When `task.dueDate` is `null` or `undefined`, the expression `task.dueDate < today` does not safely short-circuit — in JavaScript `null < "2026-11-16"` evaluates to `true`, so tasks without a due date can be incorrectly flagged as overdue.

## 6. AI Usage

- **Tool used:** Cursor with the assessment PDF attached.
- **Generated:** Project scaffolding, Dart Shelf backend, Flutter screens/widgets, Provider state management, README sections, and seed data.
- **Verified manually:** API filter/toggle/create behaviour, overdue logic for null dates and completed tasks, filter persistence on navigation, server validation error display on the add-task form, and end-to-end run on Flutter + Dart backend.