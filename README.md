# Product Catalog

A small Flutter product catalog app built for the Neurogine Junior Mobile Developer technical assessment. It consumes the free [DummyJSON](https://dummyjson.com) API to list, search, and view details of products.

## Stack

- **Flutter** (Dart SDK `^3.10.4`)
- **Provider** for state management (`ChangeNotifier` view models)
- **http** for network requests
- **cached_network_image** for image caching + placeholder / error handling

## How to run

```bash
# from the product_catalog/ folder
flutter pub get
flutter run
```

Run tests:

```bash
flutter test
```

> Tip: for a smoother demo, use `flutter run --release` — image decode and list scrolling are noticeably faster than in debug mode.

## Architecture

Two-layer split under `lib/`:

```
lib/
├── data/
│   ├── models/          # Product, ProductResponse, Category
│   ├── services/        # ProductApiService — raw HTTP + JSON
│   └── repositories/    # ProductRepository — returns domain models
└── presentation/
    ├── viewmodels/      # ProductViewModel (ChangeNotifier)
    ├── views/           # ProductListScreen, ProductDetailScreen
    └── widgets/         # ProductCard, LoadingView, ErrorView, EmptyView
```

**Why this split**

- `ProductApiService` knows about URLs and JSON only. It doesn't know what a `Product` is.
- `ProductRepository` converts raw JSON maps into domain models. This is where I'd swap in a caching layer or a different API later without touching the UI.
- `ProductViewModel` holds UI state (loading / error / list / pagination / search / filter) and exposes methods for the view. The view is dumb — it reads state and calls methods.
- Both `ProductApiService` and `ProductRepository` accept an optional constructor parameter so the view model can be tested with a fake repository (dependency injection without a DI framework).

## Features

- Product **list** — 2-column grid with title, thumbnail, price, and a rating badge
- **Pagination** — loads 20 items per page; auto-fetches the next page when the user is within 200 px of the bottom
- **Detail screen** — always refetches via `GET /products/{id}` so data is fresh; the product passed from the list is shown immediately as a placeholder so the screen never blanks out
- **Four visual states** — skeleton loader, empty state, error state with retry button, and success
- **Debounced search** (see below)
- **Category filter** — extra UX beyond the brief: filter button opens a bottom sheet with all categories as chips
- **Pull-to-refresh**
- **Image downsampling** (`memCacheWidth`) for a lighter memory footprint
- **Hero animation** on the product thumbnail into the detail screen

## Search strategy — server-side, debounced 500 ms

I chose the server endpoint (`GET /products/search?q=…`) over client-side filtering.

**Why**
- Client-side search would only match against the products already loaded in memory (the first N pages), missing everything after the last visible page. Server-side matches across the whole catalog.
- 500 ms is a middle ground — long enough to skip most keystrokes, short enough not to feel laggy.
- Pagination is disabled during search because the endpoint returns all matches in one response (no `skip` parameter for search).

## Error handling

- **Initial load fails** → full-screen `ErrorView` with a Retry button.
- **Pagination fails** (list already has items) → an inline retry tile appears at the bottom of the list. The already-loaded items stay visible.
- **Detail refresh fails** → the product passed from the list is still shown; a small amber banner at the top offers Retry.
- The view model tracks the **last failed action** as a callback. `retry()` just re-invokes it — no fragile state inference.

## Tests

- `test/product_test.dart` — JSON parsing for `Product` and `ProductResponse`, including int-vs-double edge cases and empty lists.
- `test/product_view_model_test.dart` — initial state, fetch, pagination (including rapid concurrent calls), search, refresh, and category filtering.

Note: the view model tests hit the live DummyJSON API. In a longer time-box I would inject a `FakeProductRepository` and assert against controlled fixtures — that scaffolding is already in place via the optional constructor parameters.

## What I did not finish

- **Fake-repository unit tests** — DI is wired but the tests still hit the live API.
- **Widget tests** for the list and detail screens.
- **Dark mode** — theme is defined for light mode only.
- **Localization** — copy is English-only.
- **Bigger empty / error illustrations** — currently just tinted icons.

## AI usage disclosure

The architecture, state management, features, and tests are my own work.

I used AI (Claude) as a reviewer during the polish phase — for a second opinion on edge cases (URL encoding, pagination error visibility, retry state handling) and for UI/UX guidance (Material 3 theming, replacing the horizontal category strip with a bottom sheet, moving to a responsive grid layout). I reviewed every suggestion before committing and can explain every line in the walkthrough video.
