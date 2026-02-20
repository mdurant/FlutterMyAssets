# Flutter My Assets API — Listado de rutas

Base URL por defecto: `http://localhost:3000`  
Prefijo de API: `/api/v1`

**Contrato detallado login por OTP (mensajes, códigos, flujo):** ver [FLUTTER-BACKEND-LOGIN-OTP.md](FLUTTER-BACKEND-LOGIN-OTP.md).

---

## General (sin prefijo)

| Método | Ruta | Descripción |
|--------|------|-------------|
| **GET** | `/health` | Health check. Respuesta: `{ "success": true, "data": { "status": "ok", "timestamp": "..." } }` |

---

## Información y estado

| Método | Ruta | Descripción |
|--------|------|-------------|
| **GET** | `/api/v1/` | Info de la API (nombre, versión). |
| **GET** | `/api/v1/ready` | Comprueba conexión a la base de datos. `200` → BD OK, `503` → BD no disponible. |

---

## Auth (`/api/v1/auth`)

| Método | Ruta | Descripción | Body / Query |
|--------|------|-------------|--------------|
| **POST** | `/api/v1/auth/register` | Registro de usuario. Envía correo de verificación. | Body: `email`, `password`, `nombres`, `apellidos`, `sexo` (HOMBRE\|MUJER\|OTRO), `fechaNacimiento` (ISO), `domicilio?`, `regionId?` (UUID), `comunaId?` (UUID), `acceptTerms` (boolean) |
| **GET** | `/api/v1/auth/verify-email` | Verificación de correo desde el enlace del email. | Query: `token` |
| **POST** | `/api/v1/auth/verify-email` | Verificación de correo desde cliente (Postman, app). | Body: `{ "token": "..." }` |
| **POST** | `/api/v1/auth/resend-verify-email` | Reenviar correo de verificación con un nuevo token. | Body: `{ "email": "..." }` |
| **POST** | `/api/v1/auth/login` | Login con email y contraseña. Si solo se envía `email`, envía OTP al correo. | Body: `email`, `password?` |
| **POST** | `/api/v1/auth/verify-otp` | Validar código OTP. Con `purpose: "LOGIN"` o `"EMAIL_VERIFY"` puede devolver accessToken y refreshToken. | Body: `email`, `code` (6 dígitos), `purpose?` (LOGIN\|EMAIL_VERIFY\|PASSWORD_RESET) |
| **POST** | `/api/v1/auth/refresh` | Renovar access token. Rota el refresh token. | Body: `{ "refreshToken": "..." }` |
| **POST** | `/api/v1/auth/logout` | Cerrar sesión (revocar refresh token). | Body: `{ "refreshToken": "..." }` |
| **POST** | `/api/v1/auth/password-recovery` | Solicitar restablecimiento de contraseña. Envía correo con enlace. | Body: `{ "email": "..." }` |
| **POST** | `/api/v1/auth/password-reset` | Restablecer contraseña con el token del correo. | Body: `token`, `newPassword` |
| **GET** | `/api/v1/auth/me` | Perfil del usuario autenticado. | — |
| **PATCH** | `/api/v1/auth/me` | Actualizar datos personales (nombres, apellidos, domicilio, regionId, comunaId, avatarUrl). No incluye cambio de email. | Body: campos opcionales |
| **POST** | `/api/v1/auth/me/request-email-change` | Solicitar cambio de correo. Envía token al nuevo email. Tras verificar (verify-new-email), cerrar sesión y login con nuevo correo. | Body: `{ "newEmail": "..." }`. Errores: SAME_EMAIL, EMAIL_IN_USE, EMAIL_SEND_FAILED. |
| **GET** | `/api/v1/auth/verify-new-email` | Verificación de nuevo correo desde enlace. | Query: `token` |
| **POST** | `/api/v1/auth/verify-new-email` | Verificación de nuevo correo desde cliente. | Body: `{ "token": "..." }` |

---

## Catálogo (regiones y comunas)

| Método | Ruta | Descripción | Query / Respuesta |
|--------|------|-------------|-------------------|
| **GET** | `/api/v1/regions` | Lista de regiones (Chile). Para selects en registro. | Respuesta: `{ "success": true, "data": [ { "id": "uuid", "nombre": "Región de Valparaíso" }, ... ] }` |
| **GET** | `/api/v1/comunas` | Lista de comunas de una región. | Query: `regionId` (UUID, obligatorio). Respuesta: `{ "success": true, "data": [ { "id": "uuid", "nombre": "Viña del Mar" }, ... ] }` |

---

## Resumen por módulo

| Módulo | Rutas |
|--------|--------|
| **General** | `GET /health`, `GET /api/v1/`, `GET /api/v1/ready` |
| **Auth** | Registro, verify-email, login, verify-otp, refresh, logout, password-recovery/reset; **perfil:** `GET/PATCH /api/v1/auth/me`, `POST /api/v1/auth/me/request-email-change`, `GET/POST /api/v1/auth/verify-new-email` |
| **Catálogo** | `GET /api/v1/regions`, `GET /api/v1/comunas?regionId=uuid` |

---

## Formato de respuestas

- **Éxito:** `{ "success": true, "data": { ... } }` o `{ "success": true, "data": [ ... ] }`
- **Error:** `{ "success": false, "error": "CODIGO", "message": "Mensaje legible" }`
- **Validación:** `{ "success": false, "error": "VALIDATION_ERROR", "message": "...", "details": [ ... ] }`

## Códigos HTTP habituales

- `200` — OK  
- `201` — Creado (ej. register)  
- `400` — Bad request (validación, token inválido, etc.)  
- `401` — No autorizado (credenciales, token expirado)  
- `404` — Recurso no encontrado  
- `409` — Conflicto (ej. email ya registrado)  
- `503` — Servicio no disponible (ej. BD caída)

---

## Registro mínimo (Flutter ↔ Backend)

La app Flutter usa un **registro mínimo** en "Crear cuenta": solo se piden **Nombres**, **Apellidos**, **Correo**, **Contraseña**, **Repetir contraseña** y **Aceptar términos**. El resto de datos (sexo, fecha de nacimiento, domicilio, región, comuna) el usuario los completa después en su perfil/dashboard.

**Qué envía Flutter en `POST /api/v1/auth/register`:**

| Campo            | Valor que envía Flutter | Nota |
|------------------|-------------------------|------|
| `nombres`        | Texto del formulario    | Obligatorio en UI |
| `apellidos`      | Texto del formulario    | Obligatorio en UI |
| `email`          | Texto del formulario    | Obligatorio en UI |
| `password`       | Texto del formulario    | Obligatorio en UI |
| `acceptTerms`    | `true`                  | Obligatorio en UI |
| `sexo`           | `"OTRO"`                | Por defecto (no se pide en pantalla) |
| `fechaNacimiento`| `"2000-01-01"`          | Por defecto (no se pide en pantalla) |
| `domicilio`      | `""`                    | Vacío; el usuario completa en perfil |
| `regionId`       | `""`                    | Vacío; el usuario completa en perfil |
| `comunaId`       | `""`                    | Vacío; el usuario completa en perfil |

**Flujo verificación de correo + OTP (Flutter):**

1. Usuario se registra → recibe correo con **token** de verificación.
2. Usuario ingresa el token en la app → `POST /auth/verify-email` con `token`.
3. **Backend:** al validar el token, debe enviar un **código OTP de 6 dígitos** al correo del usuario (para que la app pida ese código en la siguiente pantalla).
4. Usuario ingresa el OTP de 6 dígitos en la app → `POST /auth/verify-otp` con `email`, `code`, `purpose: "EMAIL_VERIFY"`.
5. Si el backend responde con `data: { accessToken, refreshToken }`, la app deja al usuario logueado y navega al Home. Si no devuelve tokens, la app lleva a la pantalla de bienvenida para que inicie sesión con email/contraseña.

**Si el código OTP no llega al correo (experiencia de usuario):**

- **Tras verificar el token (`verify-email`):** El backend **debe** enviar un correo con un OTP de 6 dígitos al `email` del usuario justo después de validar el token. Si no se envía, el usuario queda en la pantalla de OTP sin poder continuar. Comprobar:
  - Que tras `POST /auth/verify-email` exitoso se dispare el envío del correo con el OTP.
  - Que el correo no caiga en spam (remitente, SPF/DKIM, contenido).
- **Login con solo email:** Si el usuario inicia sesión solo con email (sin contraseña), el backend envía OTP con `POST /auth/login` body `{ "email": "..." }`. El mismo OTP debe validarse con `POST /auth/verify-otp` y `purpose: "LOGIN"`.
- **Reenviar OTP (opcional):** Para mejorar la experiencia, el backend puede exponer algo como `POST /auth/resend-otp` con body `{ "email": "...", "purpose": "EMAIL_VERIFY" }` para reenviar el código. La app ya muestra "Reenviar código" en rojo; si se implementa el endpoint, Flutter puede llamarlo en el flujo de verificación de correo.

**Requisitos para el backend (match Flutter):**

- Aceptar `domicilio`, `regionId` y `comunaId` **opcionales**: cuando vengan vacíos (`""`) o `null`, no fallar validación. Si el backend exige UUID cuando `regionId`/`comunaId` están presentes, debe tratar `""` o ausencia del campo como "no informado".
- `sexo` y `fechaNacimiento` se envían siempre con valores por defecto; el backend puede seguir requiriéndolos como hasta ahora.
- El resto de campos obligatorios del registro (email, password, nombres, apellidos, acceptTerms) se envían desde el formulario mínimo.
