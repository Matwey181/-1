# Player iOS

SwiftUI музыкальный плеер с одной оригинальной тестовой мелодией. Проект перенесён из Compose.

## Сборка IPA
Откройте **Actions → Build iOS IPA → Run workflow**. После выполнения скачайте артефакт **Player-unsigned-IPA**.

**Важно:** IPA собирается без подписи Apple и требует подписи перед установкой на iPhone. Сборка использует Xcode на GitHub Actions, а не локальную машину.

Локально: установите XcodeGen, выполните `xcodegen generate`, откройте `Player.xcodeproj` в Xcode. Для установки выберите свою команду в Signing & Capabilities.
