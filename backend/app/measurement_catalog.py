"""
Catálogo alineado con training/Ultima_version3-_resnet (2).ipynb

Orden del vector de salida (Dense(16)) = column_names del CSV / col_names en evaluación.
Unidades: centímetros (dataset SMPL).
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class MeasurementSpec:
    key: str
    label_es: str
    unit: str = "cm"


# Mismo orden que en el notebook (column_names / col_names)
MEASUREMENT_SPECS: tuple[MeasurementSpec, ...] = (
    MeasurementSpec("chest_circ", "Perímetro de pecho"),
    MeasurementSpec("waist_circ", "Perímetro de cintura"),
    MeasurementSpec("pelvis_circ", "Perímetro de cadera (pelvis)"),
    MeasurementSpec("neck_circ", "Perímetro de cuello"),
    MeasurementSpec("bicep_circ", "Perímetro de bíceps"),
    MeasurementSpec("thigh_circ", "Perímetro de muslo"),
    MeasurementSpec("knee_circ", "Perímetro de rodilla"),
    MeasurementSpec("arm_length", "Largo de brazo"),
    MeasurementSpec("leg_length", "Largo de pierna"),
    MeasurementSpec("calf_length", "Largo de pantorrilla"),
    MeasurementSpec("head_circ", "Perímetro de cabeza"),
    MeasurementSpec("wrist_circ", "Perímetro de muñeca"),
    MeasurementSpec("arm_span", "Envergadura de brazos"),
    MeasurementSpec("shoulders_width", "Ancho de hombros"),
    MeasurementSpec("torso_length", "Largo de torso"),
    MeasurementSpec("inner_leg", "Entrepierna"),
)

NUM_OUTPUTS = len(MEASUREMENT_SPECS)

# Resumen de 4 medidas para compatibilidad con la app (mapeo desde salidas del modelo)
SUMMARY_ALIASES: tuple[tuple[str, str, str], ...] = (
    # (clave_json_app, clave_modelo, etiqueta_es)
    ("waist_circumference_cm", "waist_circ", "Perímetro de cintura"),
    ("arm_width_cm", "shoulders_width", "Ancho de hombros"),
    ("hip_circumference_cm", "pelvis_circ", "Perímetro de cadera"),
    ("chest_circumference_cm", "chest_circ", "Perímetro de pecho"),
)
