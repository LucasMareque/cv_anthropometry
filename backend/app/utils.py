from __future__ import annotations

import io
import uuid
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
from PIL import Image


def read_upload_as_rgb(image_bytes: bytes) -> np.ndarray:
    """Convierte bytes de imagen (JPEG/PNG) a array RGB uint8."""
    img = Image.open(io.BytesIO(image_bytes))
    if img.mode != "RGB":
        img = img.convert("RGB")
    return np.array(img)


def ensure_dir(path: Path) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    return path


def unique_filename(prefix: str, suffix: str) -> str:
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S")
    return f"{prefix}_{ts}_{uuid.uuid4().hex[:8]}{suffix}"


def save_bytes(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
