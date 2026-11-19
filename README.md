# AI TechPulse - Modern Worldwide AI & Tech News App

A modern Flutter news application built for **Topic 11: FutureBuilder, News App & Error Handling REST API** with **GNews API**, designed with a clean, soft modern aesthetic and focused on worldwide Artificial Intelligence, semiconductor chip shortages, LLMs, robotics, and machine learning breakthroughs.

---

## 🌟 Key Features & Rubric Highlights (100% Compliance)

### 1. FutureBuilder Implementation (30% Rubric)
- **4 States Handled Gracefully**:
  1. **Loading State**: Elegant skeleton placeholder with custom progress indicators (`LoadingView`).
  2. **Error State**: Informative error card with contextual icons and an interactive **"Try Again"** button (`ErrorView`).
  3. **Empty State**: Clean illustration and feedback when zero articles are returned (`EmptyView`).
  4. **Data State**: Scrollable list of article cards with pull-to-refresh (`ArticleCard`).
- **State Management Compliance**:
  - `Future` is strictly initialized in `initState()` and managed within the `State` class.
  - **Never** created directly inside `build()`, preventing redundant network triggers on rebuilds.

### 2. Quota Saver: In-Memory Category Caching (Latihan Wajib)
- Stores category results in `Map<String, Future<List<ArticleModel>>> _categoryCache`.
- Switching between chips (e.g. *All AI Tech* ↔ *Chips & Hardware*) reuses the cached Future without consuming daily GNews API quota (100 requests/day).
- Pull-to-refresh (`RefreshIndicator`) or tapping **"Try Again"** invalidates the specific category cache and fetches fresh data.

### 3. Search Feature via Dialog & Dedicated FutureBuilder Page (Latihan Wajib)
- **Search Icon Button** in the AppBar opens an interactive dialog with quick-topic chips (*Nvidia GPU*, *OpenAI*, *Humanoid Robot*, *Quantum AI*, *TSMC*).
- Searching navigates to `SearchResultsView` via GetX routing (`/search`).
- `SearchResultsView` independently implements its own `FutureBuilder<List<ArticleModel>>` with the full 4-state lifecycle, retry mechanism, and pull-to-refresh.

### 4. Robust Error Handling with `ApiException` (30% Rubric)
Maps all Dio and HTTP errors into clear, actionable messages:
1. **Missing Configuration**: Missing or empty API key in `config/env.json`.
2. **401 Unauthorized**: Invalid or unregistered API key.
3. **403 Forbidden**: Daily request quota exceeded (100 req/day) or unverified email account.
4. **404 Not Found**: Endpoint not found.
5. **429 Rate Limit**: Too many requests (>1 request/second on free tier).
6. **500+ Server Errors**: GNews server outage or bad gateway.
7. **Network Connection Error**: No internet connection / DNS failure.
8. **Timeouts**: Connection, send, receive, and transform timeouts.
9. **Data Mismatch / TypeError**: Invalid schema from server.

### 5. Architectural Separation & Code Quality (10% Rubric)
Strict separation of concerns:
```
news_app/
├── config/
│   ├── env.example.json      # Template configuration (committed)
│   └── env.json              # Private URL & API Key (git-ignored)
├── lib/
│   ├── config/
│   │   └── env.dart          # Environment reader and key masking
│   ├── controllers/
│   │   └── detail_controller.dart # GetX controller for detail screen
│   ├── models/
│   │   ├── article_model.dart       # Article model & content cleanup
│   │   └── news_response_model.dart # API response wrapper
│   ├── routes/
│   │   ├── app_pages.dart    # GetX route definitions
│   │   └── app_routes.dart   # Route constants
│   ├── services/
│   │   ├── api_exception.dart     # Centralized exception translator
│   │   └── news_api_service.dart  # Centralized Dio HTTP client
│   ├── utils/
│   │   ├── app_colors.dart        # Soft modern color palette
│   │   └── date_formatter.dart    # Relative timeago & date formatting
│   ├── views/
│   │   ├── detail_view.dart       # Article reader with external web launcher
│   │   ├── home_view.dart         # Main feed with cached FutureBuilder
│   │   └── search_results_view.dart # Search page with FutureBuilder
│   ├── widgets/
│   │   ├── article_card.dart      # Modern card widget
│   │   ├── empty_view.dart        # Empty state widget
│   │   ├── error_view.dart        # Error state widget with retry
│   │   ├── loading_view.dart      # Skeleton loading widget
│   │   └── news_image.dart        # Web CORS-safe image loader
│   └── main.dart                  # App bootstrap & mouse drag support
└── test/
    ├── models_and_exceptions_test.dart # Unit tests for models & 6 error scenarios
    └── widget_test.dart               # Widget tests for ErrorView, EmptyView, ArticleCard
```

---

## 🚀 Setup & How to Run

### Step 1: Set your GNews API Key
1. Register for a free API key at [https://gnews.io](https://gnews.io) (make sure to verify your email).
2. Open `config/env.json`:
```json
{
  "GNEWS_BASE_URL": "https://gnews.io/api/v4",
  "GNEWS_API_KEY": "YOUR_ACTUAL_32_CHAR_HEX_API_KEY"
}
```

### Step 2: Run the App
Run on Chrome Browser (recommended for fast testing):
```bash
flutter run -d chrome --dart-define-from-file=config/env.json
```

Or run on Android / Windows Desktop:
```bash
flutter run --dart-define-from-file=config/env.json
```

### Step 3: Run the Unit & Widget Tests
```bash
flutter test
```
All 11 unit and widget tests pass:
- JSON parsing and `_rapikanContent()`
- `ApiException` mapping for 6 error scenarios
- `ErrorView` retry button callback
- `EmptyView` rendering
- `ArticleCard` tapping & date formatting

---

## 🧪 Testing Error Scenarios (Tugas Mandiri)

| Scenario | How to Trigger | Expected Displayed Message |
|---|---|---|
| **API key empty** | Run without `--dart-define-from-file` or leave key empty | `Configuration is missing. Please provide GNEWS_BASE_URL and GNEWS_API_KEY...` |
| **API key invalid (401)** | Change `GNEWS_API_KEY` to 32 zeroes `00000000000000000000000000000000` | `API key is invalid or unregistered. Please check config/env.json.` |
| **API key malformed (400)** | Change `GNEWS_API_KEY` to `invalid_key_123` | `Invalid request. The API key is malformed...` |
| **Too fast / Rate limit (429)** | Rapidly tap different category chips | `Too many requests. GNews free tier allows at most 1 request per second.` |
| **No Internet Connection** | Disconnect Wi-Fi or set Network to Offline in Chrome DevTools | `No internet connection. Please check your network connectivity.` |
| **Endpoint not found (404)** | Change endpoint path | `The requested endpoint was not found.` |
