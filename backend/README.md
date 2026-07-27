# Backend (API de inferencia)

Servidor [FastAPI](https://fastapi.tiangolo.com/) que recibe la foto desde la app Flutter y devuelve medidas antropométricas en JSON.

## Estructura

```
backend/
├── app/
│   ├── main.py          # Arranca FastAPI
│   ├── routes.py        # POST /analyze, GET /health
│   ├── config.py        # Rutas, tamaño de imagen, CORS
│   ├── preprocess.py    # Preparar imagen para el modelo
│   ├── model.py         # Cargar .keras e inferir
│   ├── measurements.py    # Salida del modelo → JSON para el móvil
│   └── utils.py         # Lectura de imagen, guardado opcional
├── weights/             # Coloca aquí tu model.keras (no se sube a Git)
├── uploads/             # Opcional: guardar fotos entrantes
├── outputs/             # Opcional: máscaras/overlays generados
├── requirements.txt
└── .env.example
```

## Puesta en marcha (desarrollo local)

1. Crea un entorno virtual e instala dependencias:

   ```powershell
   cd backend
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```

2. Copia tu modelo entrenado:

   ```text
   backend/weights/model.keras
   ```

   (o cambia `MODEL_PATH` en `.env`).

3. Arranca el servidor:

   ```powershell
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

4. Ejecuta la app desde `frontend/` (`flutter pub get`, `flutter run`) y en el menú lateral configura la URL del API:
   - Emulador Android → `http://10.0.2.2:8000`
   - Dispositivo físico en la misma Wi‑Fi → `http://IP_DE_TU_PC:8000`
   - Ruta del endpoint: `/analyze`

## Contrato con el frontend

| Flutter | Backend |
|---------|---------|
| Campo multipart `image` | `UploadFile` llamado `image` |
| Ruta `/analyze` (configurable) | `POST /analyze` |
| Tabla `measurements` (n filas) + claves planas en cm | Ver `measurement_catalog.py` |

El modelo predice **16 medidas en cm** (ver `training/README.md`). La app también recibe un `summary` de 4 medidas principales.

Peso esperado: `weights/model_ResNet50.keras`

Documentación interactiva: `http://localhost:8000/docs`
