# Entrenamiento

Todo el ciclo ML vive aquí (dataset + notebooks). No hay una carpeta `notebooks/` en la raíz del repo.

```
training/
├── dataset/
│   └── 0.create_dataset.py          # TFRecords y CSV sincronizados
├── notebooks/
│   ├── Ultima_version3-_resnet (2).ipynb   # fuente de verdad → backend
│   ├── 1.training_nb.ipynb                 # experimento anterior
│   └── 2.testing.ipynb                     # evaluación / heatmaps
└── README.md
```

**Exportar al backend:** usar `notebooks/Ultima_version3-_resnet (2).ipynb`. Ese notebook es el que coincide con `backend/app/measurement_catalog.py`.

## Lo que hace el modelo (verificado)

| Aspecto | Valor |
|---------|--------|
| Backbone | **ResNet50** (ImageNet, base congelada) |
| Entrada | **224 × 224**, RGB |
| Preprocesado | `tensorflow.keras.applications.resnet50.preprocess_input` sobre píxeles **0–255** |
| Salidas | **16** regresiones en **cm** (no 4) |
| Archivo guardado | `model_ResNet50.keras` |
| Loss | `mean_absolute_error` |

## Orden de las 16 salidas

1. chest_circ — pecho  
2. waist_circ — cintura  
3. pelvis_circ — cadera  
4. neck_circ — cuello  
5. bicep_circ — bíceps  
6. thigh_circ — muslo  
7. knee_circ — rodilla  
8. arm_length — largo brazo  
9. leg_length — largo pierna  
10. calf_length — pantorrilla  
11. head_circ — cabeza  
12. wrist_circ — muñeca  
13. arm_span — envergadura  
14. shoulders_width — ancho de hombros  
15. torso_length — torso  
16. inner_leg — entrepierna  

El backend (`backend/app/measurement_catalog.py`) replica este orden.

## Resumen de 4 medidas en la app

Para la UI simplificada, el API también expone `summary` / claves planas:

- Cintura → `waist_circ`
- “Ancho de brazo” en la app → `shoulders_width` (ancho de hombros en el dataset)
- Cadera → `pelvis_circ`
- Pecho → `chest_circ`

## Cómo usar el peso entrenado

Copia el archivo exportado de Colab a:

```text
backend/weights/model_ResNet50.keras
```

## Nota sobre el notebook

El script es coherente y coincide con los resultados impresos (MAE por columna).  
Solo asegurate de que el `.keras` que subís al backend sea el de **ResNet50** entrenado con `notebooks/Ultima_version3-_resnet (2).ipynb`.
