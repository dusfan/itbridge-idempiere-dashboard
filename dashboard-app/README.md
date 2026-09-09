# Dashboard App

A Flutter-only, responsive dashboard UI based on the supplied mobile and desktop references.

## Run

```bash
flutter pub get
flutter run
```

The UI switches at 720 logical pixels:

- **Phone:** two-column metric cards, sales chart, fixed bottom navigation.
- **Tablet / desktop:** permanent navigation rail, four-column metric grid, chart, payment status, and top-flight panels.

All content is local mock data isolated in `lib/features/dashboard/data`, so it can be swapped for an API repository later.
