# Me encontraste — Flutter

Aplicación móvil **Me encontraste** (arriendo con confianza, rating de riesgo). Este documento describe lo desarrollado hasta la fecha: comunicación con el backend, inventario de pantallas, dependencias, fuentes y tema.

---

## 1. Resumen del proyecto

- **Nombre:** Me encontraste  
- **Descripción:** Conecta personas con propiedades seguras; flujo de registro, verificación de correo, login (clásico y por OTP), recuperación y cambio de contraseña.  
- **Entrada:** Splash → Onboarding (3 pantallas) → Welcome → Login / Registro.  
- **Idioma:** Interfaces en español.  
- **Tema:** Claros en auth (paleta Me encontraste); tema global Material en modo oscuro para compatibilidad.

---

## 2. Comunicación con el Backend

### 2.1 Cliente HTTP y configuración

- **Cliente:** `Dio` (paquete `dio`).  
- **Configuración:** `lib/core/api/api_client.dart`.  
  - **Base URL por defecto:** `http://localhost:3000/api/v1` (const `kBaseUrl`).  
  - **Timeouts:** 15 s conexión y recepción.  
  - **Headers:** `Content-Type: application/json`, `Accept: application/json`.  
  - Se puede inyectar otra `baseUrl` en el constructor de `ApiClient`.

**Cambiar la URL según entorno:**

| Entorno              | Base URL recomendada                          |
|----------------------|-----------------------------------------------|
| Misma máquina        | `http://localhost:3000/api/v1`                |
| Android emulador     | `http://10.0.2.2:3000/api/v1`                |
| iOS Simulator        | `http://<IP_DE_TU_MAC>:3000/api/v1`           |
| Flutter Web          | Backend debe permitir CORS para tu origen     |

### 2.2 Autenticación (tokens)

- **Interceptor:** `_AuthInterceptor` en `ApiClient`.  
  - Añade `Authorization: Bearer <accessToken>` a todas las peticiones salvo las marcadas con `extra: { 'skipAuth': true }`.  
- **Refresh:** En respuestas 401 se intenta renovar sesión con `POST /auth/refresh` y se reenvía la petición fallida una vez.  
- **Almacenamiento:** Tokens en memoria (`_accessToken`, `_refreshToken`); se actualizan con `ApiClient().setTokens(access: ..., refresh: ...)` tras login o verify-otp.

### 2.3 Capa de API y respuestas

- **Formato de respuesta del backend:**  
  `{ "success": true|false, "data": ..., "message": "...", "error": "CODIGO" }`.  
- **Modelo en Flutter:** `lib/core/api/api_response.dart` — `ApiResponse<T>` con `success`, `data`, `message`, `errorCode`.  
- **Construcción:** `ApiResponse.fromResponse(Response)` a partir de la respuesta de Dio.

### 2.4 Módulos de API utilizados

| Módulo    | Archivo            | Descripción |
|-----------|--------------------|-------------|
| Auth      | `core/api/auth_api.dart` | Registro, verify-email, resend-verify-email, send-login-otp, login, verify-otp, refresh, logout, password-recovery, password-reset. |
| Regiones  | `core/api/regions_api.dart` | Listado de regiones y comunas (para registro; actualmente registro mínimo no los usa en UI). |
| Cliente   | `core/api/api_client.dart` | GET/POST/PUT/DELETE, baseUrl, interceptor de auth y refresh. |
| Errores   | `core/api/api_error_helper.dart` | Mensajes en español a partir de `DioException`; helpers para login-OTP y verify-otp. |

### 2.5 Endpoints que usa la app

Resumen; el listado completo está en `docs/API-BACKEND.md`. Contrato detallado de login por OTP en `docs/FLUTTER-BACKEND-LOGIN-OTP.md`.

| Método | Ruta (relativa a base) | Uso en la app |
|--------|------------------------|----------------|
| POST   | `/auth/register`        | Registro (registro mínimo: nombres, apellidos, email, contraseña, términos). |
| POST   | `/auth/verify-email`    | Verificación del token recibido por correo tras registro. |
| POST   | `/auth/resend-verify-email` | Reenviar correo de verificación. |
| POST   | `/auth/send-login-otp` | Solicitar código OTP al correo (y “Reenviar código” en pantalla OTP). |
| POST   | `/auth/login`          | Login con email + contraseña; si el backend devuelve `requiresOtp`, se muestra pantalla OTP. |
| POST   | `/auth/verify-otp`     | Validar código de 6 dígitos (purpose: LOGIN o EMAIL_VERIFY). |
| POST   | `/auth/refresh`        | Renovar access token (automático en interceptor). |
| POST   | `/auth/logout`         | Cerrar sesión (revocar refresh). |
| POST   | `/auth/password-recovery` | Solicitar restablecimiento de contraseña. |
| POST   | `/auth/password-reset` | Cambiar contraseña con token del correo. |
| GET    | `/regions`             | Lista de regiones (RegionsApi). |
| GET    | `/comunas?regionId=...`| Lista de comunas por región (RegionsApi). |

---

## 3. Inventario de pantallas (layouts)

Todas las pantallas están en tema claro con paleta **Me encontraste**, salvo donde se indica.

### 3.1 Onboarding

| Pantalla        | Archivo                          | Descripción |
|-----------------|-----------------------------------|-------------|
| **Splash**      | `features/onboarding/splash_screen.dart` | Logo “ME ENCONTRASTE”, eslogan, fondo blanco; ~2,5 s y pasa a onboarding. |
| **Onboarding**  | `features/onboarding/onboarding_screen.dart` | PageView de 3 páginas, puntos indicadores, botones “Siguiente” / “Comenzar” y “Omitir”. |

### 3.2 Auth (flujo principal)

| Pantalla              | Archivo                                   | Descripción |
|-----------------------|-------------------------------------------|-------------|
| **Welcome**           | `features/auth/screens/welcome_screen.dart` | Título “ME ENCONTRASTE”, subtítulos, botón “Comenzar gratis” → Login. |
| **Login**             | `features/auth/screens/login_screen.dart` | Email, contraseña, “Recordarme”, “¿Olvidaste tu contraseña?”, “Iniciar sesión con código”, “Iniciar sesión”, separador “O”, iconos sociales (placeholder), enlace “Regístrate”. |
| **Registro**          | `features/auth/screens/register_screen.dart` | Registro mínimo: Nombres, Apellidos, Correo, Contraseña, Repetir contraseña, términos, “Registrarme”, “Iniciar sesión”. |
| **Verificar correo**  | `features/auth/screens/verify_email_screen.dart` | Tras registro: campo para token del correo, “Verificar”, “Reenviar código”. |
| **Verificar OTP**     | `features/auth/screens/verify_otp_screen.dart` | 6 cajas para código de 6 dígitos, borde púrpura al foco, “¿No recibiste el código?” y “Reenviar código” (rojo), botón “Verificar”. Layout adaptable (LayoutBuilder). |
| **Recuperar contraseña** | `features/auth/screens/password_recovery_screen.dart` | “¿Olvidaste tu contraseña?”, correo, “Continuar”, “Ya tengo el token, cambiar contraseña”, “Volver a iniciar sesión”. |
| **Nueva contraseña**  | `features/auth/screens/password_reset_screen.dart` | “Crear nueva contraseña”, Nueva contraseña / Confirmar (con toggle visibilidad), “Cambiar contraseña”. |
| **Éxito restablecer** | `features/auth/screens/success_reset_screen.dart` | Icono (escudo + check), “¡Listo!”, mensaje de contraseña cambiada, botón “Continuar” → Login. |

### 3.3 Post-login

| Pantalla | Archivo                                | Descripción |
|----------|----------------------------------------|-------------|
| **Home** | `features/auth/screens/home_screen.dart` | Título “Me encontraste”, mensaje de bienvenida, botón “Cerrar sesión” e icono de logout en AppBar. |

### 3.4 Widgets compartidos (auth)

| Widget        | Archivo                                      | Uso |
|---------------|----------------------------------------------|-----|
| **AuthScaffold** | `features/auth/widgets/auth_scaffold.dart`  | Scaffold con fondo blanco, AppBar con flecha atrás, título y subtítulo, contenido scrollable. |
| **PrimaryButton** | `features/auth/widgets/primary_button.dart` | Botón púrpura (primary600), ancho completo, soporte `loading`. |
| **authInputDecoration** | `features/auth/widgets/auth_input_decoration.dart` | InputDecoration estándar (borde gris, foco púrpura, error rojo). |
| **authInputTextStyle** | mismo archivo | TextStyle para texto ingresado (color oscuro `MeEncontrastePalette.dark`). |
| **GradientButton** | `features/auth/widgets/gradient_button.dart` | En desuso en flujo actual; sustituido por PrimaryButton. |

---

## 4. Dependencias y librerías

Definidas en `pubspec.yaml`:

| Dependencia     | Versión  | Uso |
|-----------------|----------|-----|
| **flutter**     | SDK      | Framework. |
| **cupertino_icons** | ^1.0.8 | Iconos iOS. |
| **google_fonts**   | ^6.2.1 | Fuente **Outfit** (y otras si se añaden). |
| **dio**            | ^5.7.0 | Cliente HTTP para la API. |
| **intl**           | ^0.19.0 | Internacionalización / formatos. |

**Dev:**

| Dependencia   | Versión  | Uso |
|---------------|----------|-----|
| **flutter_test** | SDK   | Tests. |
| **flutter_lints** | ^6.0.0 | Lints recomendados. |

**SDK:** Dart `^3.11.0`.

---

## 5. Fuentes

- **Fuente principal:** **Outfit** (Google Fonts), cargada vía paquete `google_fonts`.  
- Uso típico: `GoogleFonts.outfit(...)` en títulos, subtítulos, labels, botones y mensajes.  
- No hay fuentes locales en `pubspec.yaml`; todo se resuelve por `google_fonts`.

---

## 6. Tema y paleta

- **Tema global (Material):** `lib/core/theme/app_theme.dart` — `AppTheme.dark` (tema oscuro).  
- **Paleta de la app:** `lib/core/theme/me_encontraste_palette.dart` — **MeEncontrastePalette**:
  - **Base:** black, white, dark (`#061327` para texto de inputs).
  - **Primary (púrpura):** primary25 … primary900 (botones, acentos, bordes en foco).
  - **Gray:** gray25 … gray900 (fondos, texto secundario, bordes).
  - **Error:** error500 (mensajes y bordes de error).

Las pantallas de auth usan fondo blanco, texto gris oscuro y acentos primary600; los inputs usan `authInputDecoration` y `authInputTextStyle`.

---

## 7. Modelos de datos

| Modelo   | Archivo             | Uso |
|----------|---------------------|-----|
| **Region** | `models/region.dart`   | id (UUID), nombre; respuesta de `/regions`. |
| **Comuna** | `models/comuna.dart`   | id (UUID), nombre; respuesta de `/comunas`. |
| **RegisterPayload** | `features/auth/screens/register_screen.dart` | Datos enviados al backend en registro (incluye campos por defecto para opcionales). |

---

## 8. Navegación y flujos

- **Raíz:** `main.dart` → `MaterialApp(home: AuthFlow())`.  
- **AuthFlow:** estado `_entryStep`: `splash` → `onboarding` → `welcome`. Desde welcome se abre Login con `Navigator.push`; el resto de pantallas auth se apilan o reemplazan según el caso.  
- **Tras login/verify-otp correcto:** `pushAndRemoveUntil` a `HomeScreen` manteniendo la primera ruta para que el logout tenga context válido.  
- **Logout:** `popUntil(isFirst)` y limpieza de tokens.  
- **Tras verify-email:** ir a Welcome (no a OTP).  
- **Tras cambio de contraseña:** `SuccessResetScreen` y desde ahí “Continuar” → Login (reemplazando pila).

---

## 9. Documentación de backend (en el repo)

| Documento | Contenido |
|-----------|-----------|
| **docs/API-BACKEND.md** | Listado de rutas, métodos, body, respuestas y sección registro mínimo Flutter ↔ Backend. |
| **docs/FLUTTER-BACKEND-LOGIN-OTP.md** | Contrato login por OTP: send-login-otp, login sin password, verify-otp, mensajes 200/404/503/400, Mailtrap y backend. |

---

## 10. Cómo ejecutar

```bash
flutter pub get
flutter run
```

Asegurar que el backend esté en la URL configurada en `api_client.dart` (por defecto `http://localhost:3000`) y que el prefijo de la API sea `/api/v1`. Para dispositivos/emuladores, ajustar `kBaseUrl` o inyectar `baseUrl` al crear `ApiClient` si se usa en otro punto.

---

*README-Flutter — Me encontraste. Actualizado con el estado del proyecto a la fecha.*
