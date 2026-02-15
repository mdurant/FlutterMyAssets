# fluttermyassets — APP de búsqueda y publicación de propiedades

Aplicación móvil desarrollada en Flutter para búsqueda y publicación de propiedades, con autenticación completa, verificación de correo, OTP (2FA por email), aceptación de términos y condiciones versionados, panel de administración de propiedades y detalle con Google Maps.  
Toda alta/baja/modificación queda registrada mediante auditoría (logs) en MySQL.

## Alcance funcional
- Autenticación completa:
  - Registro (Register)
  - Login
  - Recovery Password
  - Verificación de correo obligatoria antes del login
  - OTP de 6 dígitos (enviado al correo) para completar el login
- Términos y condiciones:
  - Versionamiento de T&C en BD
  - Aceptación obligatoria post-login
  - Trazabilidad completa (versión aceptada, fecha, metadata)
- Propiedades:
  - Panel de trabajo para subir/editar/publicar propiedades (previo login)
  - Dashboard de búsqueda con filtros
  - Detalle completo con Google Maps para orientación
- Auditoría:
  - Registro en BD de toda operación de alta/baja/modificación (y eventos relevantes)

## Arquitectura
> Por seguridad, la app Flutter NO se conecta directamente a MySQL.  
La arquitectura es:
- Flutter (Mobile App)
- Backend API (REST)
- MySQL (Base de datos)

## Tecnologías
- **Mobile:** Flutter (Dart)
- **Backend:** API REST (recomendado: Node.js/NestJS, Laravel o Spring Boot)
- **Database:** MySQL 8+
- **Maps:** Google Maps SDK (Flutter)

## Estructura de módulos (alto nivel)
- `mobile/`  → App Flutter
- `backend/` → API REST
- `db/`      → scripts SQL, migraciones y seeds
- `docs/`    → documentación y diagramas
- `devops/`  → docker-compose, CI/CD (si aplica)

## Convención Git (branching)
- `main`: producción
- `develop`: integración
- `feature/*`: nuevas funcionalidades
- `release/*`: estabilización
- `hotfix/*`: correcciones urgentes

## Autor
**Mauricio Durán T**  
CTO — IntegralTech Service Spa Chile
