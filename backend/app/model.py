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
