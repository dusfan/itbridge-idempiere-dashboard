# iDempiere Sales Order App

A Flutter mobile app for iDempiere: log in with a one-step login, browse Sales
Orders, and create new orders with line items — all through iDempiere's REST
API.

## Screens

- **Splash** → **Login** (server URL, email, password, language) → **Select
  Role** (tenant/role/org/warehouse, fires the actual login)
- **Orders** — list of Sales Orders, pull to refresh
- **Create Order** — pick a business partner, doc type, and add line items
- **Order Detail** — header info plus line items

## Stack

- Flutter
- [`idempiere_rest`](https://pub.dev/packages/idempiere_rest) for the REST
  client (one-step login, generic model CRUD, `$filter`/`$expand` query
  builders)
- `provider` for session state
- `shared_preferences` to remember the server URL and email between runs

## Setup

```bash
flutter pub get
flutter run -d chrome   # or -d windows / an Android device
```

On first launch, enter your iDempiere server's base URL (e.g.
`http://localhost:8080/api/v1`), your credentials, and the tenant/role/org IDs
for the account you're logging in as.

### Note on the `idempiere_rest` dependency

This project pins `idempiere_rest` to a local patched copy under
`vendor/idempiere_rest` (see `pubspec.yaml`'s `dependency_overrides`). The
published `1.0.2` version's `oneStepLogin()` throws a
`LateInitializationError` before the login request is ever sent — see
`vendor/idempiere_rest/lib/src/idempiere_client.dart` for the one-method fix.
Safe to remove once that fix lands upstream.
