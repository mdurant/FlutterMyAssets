# Perfil de usuario — contrato Backend ↔ Flutter

La app Flutter usa los endpoints bajo **`/api/v1/auth`** para la pantalla **Configuración**: datos del usuario, actualización de perfil y **cambio de correo con verificación**.

---

## Rutas (prefijo `/api/v1`)

| Método | Ruta | Descripción |
|--------|------|-------------|
| **GET** | `/auth/me` | Devuelve el perfil del usuario autenticado (Authorization: Bearer &lt;token&gt;). |
| **PATCH** | `/auth/me` | Actualiza datos personales: nombres, apellidos, domicilio, regionId, comunaId, avatarUrl. **No incluye cambio de email.** |
| **POST** | `/auth/me/request-email-change` | Solicitar cambio de correo. Envía token al **nuevo** email. Tras verificar (verify-new-email), el usuario debe cerrar sesión e iniciar sesión con el nuevo correo. Body: `{ "newEmail": "..." }`. Errores: SAME_EMAIL, EMAIL_IN_USE, EMAIL_SEND_FAILED. |
| **POST** | `/auth/me/avatar` | Subida de foto de perfil (multipart). |

---

## GET /auth/me

**Headers:** `Authorization: Bearer <accessToken>`

**Respuesta esperada (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "usuario@ejemplo.cl",
    "nombres": "Juan",
    "apellidos": "Pérez",
    "domicilio": null,
    "regionId": null,
    "comunaId": null,
    "avatarUrl": "/uploads/avatars/uuid.jpg"
  }
}
```

- `avatarUrl` puede ser `null` o una URL relativa. Flutter concatena con la base del servidor para mostrar la imagen.

---

## PATCH /auth/me

**Headers:** `Authorization: Bearer <accessToken>`

**Body (JSON), todos opcionales:**
```json
{
  "nombres": "Juan",
  "apellidos": "Pérez",
  "domicilio": "Calle 123",
  "regionId": "uuid",
  "comunaId": "uuid",
  "avatarUrl": "/uploads/avatars/abc.jpg"
}
```

**No se envía `email`** en PATCH. El cambio de correo es un flujo aparte (request-email-change + verify-new-email).

**Respuesta (200):** igual que GET /auth/me (objeto `data` con el perfil actualizado).

---

## POST /auth/me/request-email-change

**Headers:** `Authorization: Bearer <accessToken>`

**Body:**
```json
{
  "newEmail": "nuevo@ejemplo.cl"
}
```

- El backend envía un correo con token al **nuevo** email.
- El usuario valida con **GET** o **POST** `/api/v1/auth/verify-new-email` (token en query o body).
- Tras verificación exitosa, el usuario debe **cerrar sesión** e **iniciar sesión** con el nuevo correo.

**Errores (4xx):**
- `SAME_EMAIL` — El nuevo correo es igual al actual.
- `EMAIL_IN_USE` — El correo ya está en uso por otra cuenta.
- `EMAIL_SEND_FAILED` — No se pudo enviar el correo.

---

## GET /api/v1/auth/verify-new-email y POST

- **GET** `/api/v1/auth/verify-new-email?token=...` — Verificación desde el enlace del correo.
- **POST** `/api/v1/auth/verify-new-email` con body `{ "token": "..." }` — Verificación desde cliente/app.

Tras éxito, la app muestra mensaje de éxito, cierra sesión y lleva al usuario al login para que use el nuevo correo.

---

## POST /auth/me/avatar

**Headers:** `Authorization: Bearer <accessToken>`  
**Content-Type:** `multipart/form-data`

**Body (multipart):** campo `file` (imagen).

**Respuesta esperada (200):**
```json
{
  "success": true,
  "data": { "avatarUrl": "/uploads/avatars/abc123.jpg" }
}
```
o `{ "success": true, "avatarUrl": "..." }`. Flutter acepta ambos.

---

## Resumen para Backend

1. **GET /auth/me** — Devuelve `id`, `email`, `nombres`, `apellidos`, `domicilio`, `regionId`, `comunaId`, `avatarUrl`.
2. **PATCH /auth/me** — Actualiza solo datos personales (sin email).
3. **POST /auth/me/request-email-change** — Body `newEmail`; envía token al nuevo correo; errores SAME_EMAIL, EMAIL_IN_USE, EMAIL_SEND_FAILED.
4. **GET/POST /auth/verify-new-email** — Valida token; tras éxito el usuario debe cerrar sesión y loguearse con el nuevo correo.
5. **POST /auth/me/avatar** — Multipart con `file`; devuelve `avatarUrl`.
