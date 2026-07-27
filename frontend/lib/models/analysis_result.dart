import 'package:create_app_flutter/models/measurement_row.dart';

/// Respuesta del backend: 16 medidas (cm) + resumen de 4 para la UI.
class AnalysisResult {
  const AnalysisResult({
    this.measurements = const [],
    this.summary = const [],
    this.waistCircumferenceCm,
    this.armWidthCm,
    this.hipCircumferenceCm,
    this.chestCircumferenceCm,
    this.confidence,
    this.raw,
  });

  final List<MeasurementRow> measurements;
  final List<MeasurementRow> summary;
  final double? waistCircumferenceCm;
  final double? armWidthCm;
  final double? hipCircumferenceCm;
  final double? chestCircumferenceCm;
  final double? confidence;
  final Map<String, dynamic>? raw;

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    double? pickDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    List<MeasurementRow> parseList(dynamic list) {
      final rows = <MeasurementRow>[];
      if (list is! List) return rows;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          rows.add(MeasurementRow.fromJson(item));
        } else if (item is Map) {
          rows.add(MeasurementRow.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      rows.sort((a, b) => a.order.compareTo(b.order));
      return rows;
    }

    final all = parseList(json['measurements']);
    final summaryRows = parseList(json['summary']);

    return AnalysisResult(
      measurements: all,
      summary: summaryRows,
      waistCircumferenceCm: pickDouble(
        json['waist_circumference_cm'] ?? json['perimetro_cintura_cm'] ?? json['waist_circ'],
      ),
      armWidthCm: pickDouble(
        json['arm_width_cm'] ?? json['ancho_brazo_cm'] ?? json['shoulders_width'],
      ),
      hipCircumferenceCm: pickDouble(
        json['hip_circumference_cm'] ?? json['perimetro_cadera_cm'] ?? json['pelvis_circ'],
      ),
      chestCircumferenceCm: pickDouble(
        json['chest_circumference_cm'] ?? json['perimetro_pecho_cm'] ?? json['chest_circ'],
      ),
      confidence: pickDouble(json['confidence'] ?? json['confianza']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  /// Tabla principal: las 16 del modelo; si no vienen, el resumen de 4; si no, claves planas.
  List<MeasurementRow> get tableRows {
    if (measurements.isNotEmpty) return measurements;
    if (summary.isNotEmpty) return summary;

    final fallback = <MeasurementRow>[];
    void add(String key, String label, double? v, int order) {
      if (v == null) return;
      fallback.add(
        MeasurementRow(key: key, label: label, valueCm: v, order: order),
      );
    }

    add('waist_circumference_cm', 'Perímetro de cintura', waistCircumferenceCm, 0);
    add('arm_width_cm', 'Ancho de hombros', armWidthCm, 1);
    add('hip_circumference_cm', 'Perímetro de cadera', hipCircumferenceCm, 2);
    add('chest_circumference_cm', 'Perímetro de pecho', chestCircumferenceCm, 3);
    return fallback;
  }

  /// Las 4 medidas destacadas (resumen clínico simplificado).
  List<MeasurementRow> get summaryRows {
    if (summary.isNotEmpty) return summary;
    return tableRows.length <= 4 ? tableRows : tableRows.take(4).toList();
  }

  bool get hasAnyMeasurement => tableRows.isNotEmpty;
}
