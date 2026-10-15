# Post Reader & Favorites

ITP107 Mobile Application Development – Finals Laboratory Examination.

A Flutter app that reads English posts from the [DummyJSON API](https://dummyjson.com/posts),
opens a post on its own screen, creates new posts with an HTTP POST request, and keeps favorite posts on the
device with Hive.

## Packages

| Package | Version | Used for |
|---|---|---|
| `http` | ^1.6.0 | `http.get` to load posts, `http.post` to create one |
| `hive` | ^2.2.3 | Local key-value storage for favorites (`put`, `values`, `delete`) |
| `hive_flutter` | ^1.1.0 | `Hive.initFlutter()` and `box.listenable()` for live-updating lists |
| `google_fonts` | ^6.3.0 | Libre Bodoni (headings) and Public Sans (body text) in `ThemeData` |
| `cupertino_icons` | ^1.0.8 | Icon font referenced by Flutter's built-in Cupertino widgets |

Built and tested with Flutter 3.27.3 / Dart 3.6.1 on an Android emulator (Pixel 9 Pro, Android 16).

- **Fonts:** The font files are bundled in `assets/google_fonts/` (with their OFL licenses), so
  `google_fonts` loads them from the app instead of downloading them. The design looks the same offline.
- **Android:** The `INTERNET` permission is declared in `android/app/src/main/AndroidManifest.xml`. The build
  uses Android Gradle Plugin 8.6.1 and Gradle 8.7, which work with the Java 21 runtime bundled with
  current Android Studio. The original AGP 8.1.0 fails to build with Java 21.
- **macOS:** `com.apple.security.network.client` is enabled in both `macos/Runner/*.entitlements`, because the
  sandbox otherwise blocks `http` requests.

## Features

**Part 1 – Routes & Navigation** (`lib/main.dart`, `lib/constants.dart`)
- `MaterialApp` with `initialRoute` and three named `routes`: `/` (Posts), `/details` (Post Details), `/favorites` (Favorites).
- `Navigator.pushNamed` opens screens, and the back buttons call `Navigator.pop`. The heart button in the Posts AppBar opens Favorites.
- A tapped post's `id`, `title`, and `body` are passed as `arguments` and read with
  `ModalRoute.of(context)!.settings.arguments`.

**Part 2 – Fetch Data from the Internet** (`lib/screens/posts_screen.dart`)
- `initState()` calls the async `_fetchPosts()`, which sends `http.get(Uri.parse(...))`.
- Status 200: the body is parsed with `jsonDecode`, the `posts` list is read from it, and the posts are shown with
  `ListView.builder` + `ListTile`.
- Any other status code, or an exception (e.g. no internet), shows an error message with a **Try again** button.
- The **New post** button opens a dialog whose title and body fields cannot be empty. The data is sent with
  `http.post` + `jsonEncode`. A success message shows on status 201 and a failure message otherwise.

**Part 3 – Local Persistence with Hive** (`lib/main.dart`, `details_screen.dart`, `favorites_screen.dart`)
- `main()` calls `WidgetsFlutterBinding.ensureInitialized()`, `await Hive.initFlutter()`, and opens `favoritePostsBox` before `runApp()`.
- **Create:** "Save to Favorites" stores the post as a Map with `put()`, using the post id as the key, so a post is never saved twice.
- **Read:** the Favorites screen lists `box.values`.
- **Update:** "Add note" / "Edit note" saves a personal note back to the box.
- **Delete:** the trash icon or swiping a card left calls `delete()`. **Undo** restores the post.
- Favorites are stored on the device, so they remain after the app is closed and reopened.

**Design:** one shared `ThemeData` (`lib/theme/app_theme.dart`) with an editorial palette: ink black, warm white,
and a pink accent used only for favorites and the main action. Every screen uses the same AppBar, card, button,
dialog, and message styles. Loading, error, and empty states use the same layout across screens.

## Project structure

```
lib/
  main.dart                  App entry: Hive setup, theme, named routes
  constants.dart             Route names, API URL, Hive box name
  models/
    post.dart                Post parsed from the API
    favorite_post.dart       Favorite stored in Hive (as a Map) with a note
  screens/
    posts_screen.dart        '/'          GET list, error state, POST dialog
    details_screen.dart      '/details'   Post details + Save to Favorites
    favorites_screen.dart    '/favorites' Read, edit note, delete
  theme/app_theme.dart       Colors, fonts, and component styles
  utils/formatting.dart      Text/date formatting and readable-width padding
  widgets/                   Reusable dialogs, header, snack bar, state messages
```

## Running

```
flutter pub get
flutter run
```

The device needs internet access to load and create posts. Fonts are bundled, so they work offline.

On the web, `flutter run -d chrome` opens a fresh browser profile each time, so saved favorites appear to vanish
between runs. To show persistence on the web, run `flutter run -d web-server --web-port 8080` and open
`http://localhost:8080` in your normal Chrome. On an Android emulator or a phone, favorites persist normally.
