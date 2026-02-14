# App Store Connect - Review Notes

## App test information
- The app opens a web-based game experience hosted at:
  - https://memory-stacker.netlify.app/
- No login/account is required.
- The service is publicly accessible.

## Steps to test
1. Launch the app.
2. Wait for the loading animation to finish.
3. Verify the game home screen is displayed.
4. Use the bottom native bar:
   - `Istatistik`: Opens native local stats sheet.
   - `Yenile`: Reloads web game page.
   - `Ayarlar`: Opens native settings sheet.
5. In `Ayarlar`, toggle:
   - `Ekrani Acik Tut`
   - `Haptik Geri Bildirim`
6. Close and reopen `Istatistik` to verify local stats are stored on device.

## Native functionality included
- Native bottom control bar (SwiftUI)
- Native settings screen (on-device preferences)
- Native local statistics screen (on-device usage metrics)
- Haptic feedback integration

## Availability and stability
- Web content uses HTTPS only.
- If connection fails, app shows a retry/home error UI.
- External links are opened outside the app.

## Notes for reviewer
- This app is designed as a hybrid experience combining web gameplay with native iOS controls and local features.
