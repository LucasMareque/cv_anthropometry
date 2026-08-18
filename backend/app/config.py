from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

# Raíz del paquete backend/ (un nivel arriba de app/)
BACKEND_ROOT = Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=BACKEND_ROOT / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    api_host: str = "0.0.0.0"
    api_port: int = 8000

    # Guardado en Colab como model_ResNet50.keras (ver training/notebooks/)
    model_path: Path = BACKEND_ROOT / "weights" / "model_ResNet50.keras"
    image_size: int = 224

    uploads_dir: Path = BACKEND_ROOT / "uploads"
    outputs_dir: Path = BACKEND_ROOT / "outputs"

    save_uploads: bool = False
    save_outputs: bool = False

    # Para desarrollo con el emulador/dispositivo: "*" o lista separada por comas
    cors_origins: str = "*"


settings = Settings()
