"""
Preprocesado idéntico al notebook de entrenamiento:

  resize(224, 224) → resnet50.preprocess_input (entrada RGB 0–255)
"""

from __future__ import annotations

import numpy as np

from app.config import settings


def preprocess(image_rgb: np.ndarray) -> np.ndarray:
    """
    Entrada: H x W x 3, uint8 RGB (foto del móvil).
    Salida: (1, 224, 224, 3) float32, lista para model.predict.
    """
    import cv2
    from tensorflow.keras.applications.resnet50 import preprocess_input

    size = settings.image_size
    resized = cv2.resize(image_rgb, (size, size), interpolation=cv2.INTER_AREA)
    # El notebook aplica preprocess_input sobre píxeles 0–255 (decode_png + resize)
    batch = np.expand_dims(resized.astype(np.float32), axis=0)
    return preprocess_input(batch)
