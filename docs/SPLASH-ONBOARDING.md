# Splash y onboarding

## Logo y splash nativo

- **Logo de la app:** `assets/logo.png` (pin con casa y texto BUSCAME, fondo negro).
- El **splash nativo** (lo que ve el usuario al abrir la app antes de que cargue Flutter) se genera con **flutter_native_splash**.

### Generar el splash nativo

Tras cambiar el logo o la configuración en `pubspec.yaml`, ejecuta en la raíz del proyecto:

```bash
dart run flutter_native_splash:create
```

Esto actualiza los recursos nativos en iOS, Android y Web. La configuración está en `pubspec.yaml` bajo `flutter_native_splash`:

- Fondo negro (`#000000`), imagen central `assets/logo.png`.
- Android 12+: mismo color e imagen, icon_background_color negro.

### Flujo en la app

1. **Splash nativo** (generado): se muestra al abrir la app hasta que Flutter dibuja el primer frame.
2. **Preserve:** en `main()` se llama a `FlutterNativeSplash.preserve()` para mantener el splash nativo visible.
3. **Splash en Flutter** (`SplashScreen`): pantalla con el mismo logo y texto "BUSCAME" durante ~2,5 s.
4. Al terminar el delay, se llama a `FlutterNativeSplash.remove()` y luego `onFinish()` → onboarding o bienvenida.

## Onboarding (Img1, Img2, Img3)

- **Img1:** `assets/onboarding/img1.png` — interiores/exteriores con formas y líneas púrpura.
- **Img2:** `assets/onboarding/img2.png` — sala de estar y ciudad/avión.
- **Img3:** `assets/onboarding/img3.png` — handshake y living con tinte púrpura.

Las tres se usan en `OnboardingScreen` en un `PageView` con títulos y subtítulos en español. Los textos son los mismos que antes; solo se reemplazaron los íconos por estas imágenes.

## Icono de la app (launcher)

El mismo logo (`assets/logo.png`) se usa como icono de la app en el launcher (Android e iOS) mediante **flutter_launcher_icons**.

### Generar los iconos del launcher

En la raíz del proyecto ejecuta:

```bash
dart run flutter_launcher_icons
```

Esto genera/actualiza los iconos en `android/app/src/main/res/` e `ios/Runner/Assets.xcassets/AppIcon.appiconset/`. La configuración en `pubspec.yaml` usa fondo negro para el ícono adaptativo de Android (`adaptive_icon_background` y `adaptive_icon_foreground`).
