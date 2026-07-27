from __future__ import annotations

from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile

from app.config import settings
from app.measurements import predictions_to_response
from app.model import ModelNotLoadedError, run_model
from app.preprocess import preprocess
from app.utils import ensure_dir, read_upload_as_rgb, save_bytes, unique_filename

router = APIRouter()


@router.get("/health")
async def health():
    return {"status": "ok"}


@router.post("/analyze")
async def analyze(image: UploadFile = File(...)):
    """
    Recibe la foto del móvil (campo multipart 'image', como en Flutter).
    Devuelve medidas en centímetros + confianza.
    """
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="El archivo debe ser una imagen.")

    data = await image.read()
    if not data:
        raise HTTPException(status_code=400, detail="Imagen vacía.")

    if settings.save_uploads:
        uploads = ensure_dir(settings.uploads_dir)
        name = unique_filename("upload", Path(image.filename or "img.jpg").suffix or ".jpg")
        save_bytes(uploads / name, data)

    try:
        rgb = read_upload_as_rgb(data)
        batch = preprocess(rgb)
        raw = run_model(batch)
        result = predictions_to_response(raw)
    except ModelNotLoadedError as e:
        raise HTTPException(status_code=503, detail=str(e)) from e
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e)) from e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en inferencia: {e}") from e

    return result
