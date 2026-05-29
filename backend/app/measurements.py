"""Salida del modelo (16 regresiones en cm) → JSON con tabla + resumen de 4 medidas."""

from __future__ import annotations

from typing import Any

import numpy as np

from app.measurement_catalog import (
    MEASUREMENT_SPECS,
    NUM_OUTPUTS,
    SUMMARY_ALIASES,
)


def predictions_to_response(raw: np.ndarray) -> dict[str, Any]:
    flat = np.asarray(raw).reshape(-1).astype(float)

    if flat.size != NUM_OUTPUTS:
        raise ValueError(
            f"El modelo devolvió {flat.size} valores; se esperaban {NUM_OUTPUTS} "
            f"(ResNet50 + Dense(16) según el notebook). "
            "¿Es el archivo model_ResNet50.keras?"
        )

    by_key: dict[str, float] = {}
    table: list[dict[str, Any]] = []

    for order, (spec, value_cm) in enumerate(zip(MEASUREMENT_SPECS, flat)):
        rounded = round(float(value_cm), 2)
        by_key[spec.key] = rounded
        table.append(
            {
                "order": order,
                "key": spec.key,
                "label": spec.label_es,
                "value_cm": rounded,
                "unit": spec.unit,
            }
        )

    summary: list[dict[str, Any]] = []
    for alias_key, model_key, label in SUMMARY_ALIASES:
        summary.append(
            {
                "key": alias_key,
                "source_key": model_key,
                "label": label,
                "value_cm": by_key[model_key],
                "unit": "cm",
            }
        )

    payload: dict[str, Any] = {
        "model_backbone": "ResNet50",
        "measurements": table,
        "summary": summary,
        "count": NUM_OUTPUTS,
        "unit": "cm",
    }

    for row in table:
        payload[row["key"]] = row["value_cm"]

    for item in summary:
        payload[item["key"]] = item["value_cm"]

    spread = float(np.std(flat))
    payload["confidence"] = round(max(0.0, min(1.0, 1.0 - spread / 100.0)), 3)

    return payload
