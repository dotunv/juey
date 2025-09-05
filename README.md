# jueymobile

A new Flutter project.

## Launcher icons and brand assets

- Brand SVG: `assets/icons/app_icon.svg`
- Rasterized PNGs for launcher icons:
  - `assets/icons/app_icon.png` (1024x1024)
  - `assets/icons/app_icon_foreground.png` (1024x1024, transparent background, spark-focused)

### Dependencies
- UI: `flutter_svg`
- Icon generation: `flutter_launcher_icons`

These are configured in `pubspec.yaml` under `dependencies`, `dev_dependencies`, `flutter.assets`, and `flutter_icons`.

### Generate launcher icons
1. Ensure Flutter is installed and run:
   - `flutter pub get`
   - `flutter pub run flutter_launcher_icons`
2. Android uses adaptive icons with background `#0E0E0E` and the spark PNG foreground.
3. iOS icons are generated from `assets/icons/app_icon.png`.

### QA checklist
- AppBar shows the brand SVG at 24px on Home screen.
- Suggestion cards display a spark badge at top-right.
- Build succeeds on Android and iOS.
