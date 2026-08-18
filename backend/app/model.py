"""Carga del modelo Keras e inferencia."""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path

import numpy as np

from app.config import settings


class ModelNotLoadedError(RuntimeError):
    pass


@lru_cache(maxsize=1)
def load_model():
    path = Path(settings.model_path)
    if not path.is_file():
        raise ModelNotLoadedError(
            f"No se encontró el modelo en {path}. "
            "Coloca model_ResNet50.keras en backend/weights/ (exportado del notebook)."
        )
    import tensorflow as tf

    return tf.keras.models.load_model(path)


def run_model(batch: np.ndarray) -> np.ndarray:
    """Ejecuta inferencia y devuelve la salida cruda del modelo (numpy)."""
    model = load_model()
    return model.predict(batch, verbose=0)


def model_health() -> dict:
    """
    Estado real del modelo, sin cargarlo (para no hacer lento a /health).

    El archivo .keras no se versiona en Git: si falta, el API está vivo
    pero no puede analizar fotos.
    """
    path = Path(settings.model_path)
    file_exists = path.is_file()
    in_memory = load_model.cache_info().currsize > 0
    return {
        "status": "ok" if file_exists else "degraded",
        "model_path": str(path),
        "model_file_exists": file_exists,
        "model_loaded": in_memory,
        "ready_to_analyze": file_exists,
    }
