## Cow Master Demo

This is a Flutter demo application for managing cattle records, events, notifications, finances (incomes/expenses) and simple reports. It is intended as a working prototype and UI reference — not a production-ready system. The project uses `ValueNotifier`-based in-memory stores for reactive UI updates.

**Status:** Prototype — in-memory storage (no persistence). Features are implemented as Flutter screens and bottom-sheets.

**Platforms:** Flutter multi-platform (Android, iOS, Windows, macOS, Linux, Web) depending on your Flutter SDK and device availability.

**Primary goals:**
- Provide a cattle management UI (events, pregnancy, conditions).
- Track notifications/tasks and link them to cattle.
- Record finance entries (incomes & expenses) and simple reports.
- Demonstrate UI components, navigation and state handling.

**Where to look (key files)**
- **Models:** `lib/models/cattle.dart`, `lib/models/event_log.dart`, `lib/models/notification.dart`, `lib/models/finance_entry.dart`, `lib/models/report.dart`
- **Store:** `lib/models/cattle_store.dart` — central, reactive in-memory store powered by `ValueNotifier`
- **Pages / UI:** `lib/home_page.dart`, `lib/cattle_page.dart`, `lib/finance_page.dart`, `lib/reports_page.dart`, `lib/finance_page.dart`
- **Entry point:** `lib/main.dart` (standard Flutter entry)

**Notable behaviours**
- Incomes / Expenses: unified `FinancePage` with tabs (Incomes / Expenses); amounts shown with `R` (Rands). Add new entries with the green `+` FAB and toggle between tabs without returning to home.
- Reports: `ReportsPage` supports adding simple report entries via `+` and shows a list.
- Events & Notifications: event logging, detail dialogs, pregnancy duration display for females, and task notifications linked to cattle.

## Getting started

1. Install Flutter (if not already): follow the official instructions at https://docs.flutter.dev/get-started/install

2. From PowerShell (Windows), fetch packages:

```powershell
cd "c:\Users\matsh\OneDrive\Documents\My Work\cow_master_demo\cow_master_demo"
flutter pub get
```

3. Run the app on a connected device or desktop target. Example (Windows):

```powershell
flutter run -d windows
```

Or run on an available mobile simulator / device:

```powershell
flutter devices
flutter run -d <device-id>
```

## Development notes
- The app uses `CattleStore` (`lib/models/cattle_store.dart`) as an in-memory data hub. UI widgets use `ValueListenableBuilder` to react to changes.
- Finance and report entries are currently stored in-memory. To persist across restarts, add a persistence layer (suggested: Hive or `shared_preferences`).

### How to add persistence (short)
- Use `hive` for structured, offline storage of lists. Add dependency in `pubspec.yaml` and write adapters for `FinanceEntry`, `Report`, and `Cattle`.
- Alternatively use `shared_preferences` for lightweight JSON blobs: serialize `CattleStore` lists to JSON and save/load at startup.

## Testing & linting
- Run unit/widget tests (if present):

```powershell
flutter test
```

- Analyze the project:

```powershell
flutter analyze
```

## Further improvements (suggested)
- Persist data using Hive or SQLite (moor/drift) — recommended for production.
- Replace placeholder icons with custom cattle SVGs or assets to match exact branding/screenshots.
- Improve Add-Income/Add-Expense sheet to support categories, installments, and advanced date selection (screenshots show an installments UI).
- Polish visual details (exact paddings, fonts, rounded card styles) to achieve pixel-perfect parity with the provided screenshots.

## Contributing
- Fork the repo and open a PR with focused changes. Keep commits small and tests passing.

## License
- This demo has no specific license file. Add a license (e.g., MIT) if you plan to publish or collaborate publicly.

## Questions / Next steps
If you want I can:
- add data persistence (Hive or shared_preferences) so finance/reports survive restarts,
- implement the installments and category UI in the finance add sheet to match screenshots,
- replace icons with provided SVG assets and tune exact layout/padding.

Tell me which of these you want next and I will implement it.
