# Arquitectura del proyecto

Monorepo típico para app móvil + API:

```
cibio_anthropometry/
├── frontend/       # App Flutter (cámara + UI)
├── backend/        # API Python (FastAPI + Keras)
└── docs/           # Notas y guías
```

## Flujo de una captura

```mermaid
sequenceDiagram
    participant U as Usuario
    participant F as App Flutter
    participant R as routes.py
    participant P as preprocess.py
    participant M as model.py
    participant Me as measurements.py

    U->>F: Toma foto (pose en T)
    F->>R: POST /analyze (multipart image)
    R->>P: Preparar tensor
    P->>M: Inferencia .keras
    M->>Me: Vector / máscara cruda
    Me->>R: JSON (cm, confianza)
    R->>F: Respuesta HTTP
    F->>U: Muestra perímetros aprox.
```

## Nota sobre PyTorch vs Keras

Tu plantilla mencionaba `model.pt` (PyTorch). En este repositorio el modelo es **TensorFlow/Keras** (`.keras`), coherente con el frontend.
