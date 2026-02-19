# Perfil de usuario — contrato Backend ↔ Flutter

La app Flutter necesita estos endpoints para la pantalla **Cuenta**: datos del usuario, actualización de perfil y **subida de foto de perfil (avatar)** desde el dispositivo.

---

## Rutas recomendadas (prefijo `/api/v1`)

| Método | Ruta | Descripción |
|--------|------|-------------|
| **GET** | `/users/me` | Devuelve el perfil del usuario autenticado (Authorization: Bearer &lt;token&gt;). |
| **PATCH** | `/users/me` | Actualiza campos del perfil (nombres, apellidos, etc.). |
| **POST** | `/users/me/avatar` | Subida de foto de perfil (multipart). |

---

## GET /users/me

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
    "avatarUrl": "/uploads/avatars/uuid.jpg"
  }
}
```

- `avatarUrl` puede ser `null` o una URL **relativa** (ej. `/uploads/avatars/...`). Flutter concatena con la base del servidor para mostrar la imagen.
- Si el usuario no tiene foto, la app muestra un avatar por defecto (iniciales o ícono).

---

## PATCH /users/me

**Headers:** `Authorization: Bearer <accessToken>`

**Body (JSON):**
```json
{
  "nombres": "Juan",
  "apellidos": "Pérez"
}
```

Campos opcionales. Solo se envían los que se desean actualizar.

**Respuesta (200):** igual que GET /users/me (objeto `data` con el perfil actualizado).

---

## POST /users/me/avatar

**Headers:** `Authorization: Bearer <accessToken>`  
**Content-Type:** `multipart/form-data`

**Body (multipart):**
- Campo: `file` (archivo de imagen desde galería o cámara).
- Flutter envía el archivo con nombre de campo `file`.

**Requisitos sugeridos para el backend:**
- Aceptar formatos: JPEG, PNG, WebP.
- Tamaño máximo recomendado: 2–5 MB.
- Redimensionar/recortar en servidor si se desea (ej. 400x400) y guardar en `/uploads/avatars/` o similar.
- Guardar la referencia en el usuario (ej. `avatarUrl`) y devolverla en la respuesta.

**Respuesta esperada (200):**
```json
{
  "success": true,
  "data": {
    "avatarUrl": "/uploads/avatars/abc123.jpg"
  }
}
```

O en formato plano:
```json
{
  "success": true,
  "avatarUrl": "/uploads/avatars/abc123.jpg"
}
```

Flutter acepta ambos (busca `data.avatarUrl` o `avatarUrl` en la raíz).

---

## Resumen para Backend

1. **GET /users/me** — Devuelve `id`, `email`, `nombres`, `apellidos`, `avatarUrl` del usuario identificado por el JWT.
2. **PATCH /users/me** — Actualiza `nombres` y/o `apellidos`; responde con el perfil actualizado.
3. **POST /users/me/avatar** — Multipart con campo `file`; guarda la imagen, actualiza `avatarUrl` del usuario y devuelve la URL (relativa o absoluta).

Con esto la app puede mostrar nombre, correo y avatar en la pantalla Cuenta y permitir cambiar la foto desde el dispositivo.

---

## Flutter: permisos para foto de perfil

La app usa **image_picker** para galería y cámara. En **iOS** (`ios/Runner/Info.plist`) añade:

- `NSPhotoLibraryUsageDescription` — para elegir foto desde la galería.
- `NSCameraUsageDescription` — para tomar foto con la cámara.

En **Android** (API 33+), los permisos de lectura de medios se piden en tiempo de ejecución; para cámara puede ser necesario `android.permission.CAMERA` en `AndroidManifest.xml` si usas cámara.
