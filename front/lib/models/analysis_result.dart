/// Respuesta esperada del backend (TensorFlow).
/// Ajusta los nombres de las claves JSON cuando definas el contrato real del API.
class AnalysisResult {
  const AnalysisResult({
    this.waistCircumferenceCm,
    this.armWidthCm,
    this.hipCircumferenceCm,
    this.chestCircumferenceCm,
    this.confidence,
    this.raw,
  });

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

    return AnalysisResult(
      waistCircumferenceCm: pickDouble(
        json['waist_circumference_cm'] ?? json['perimetro_cintura_cm'],
      ),
      armWidthCm: pickDouble(
        json['arm_width_cm'] ?? json['ancho_brazo_cm'],
      ),
      hipCircumferenceCm: pickDouble(
        json['hip_circumference_cm'] ?? json['perimetro_cadera_cm'],
      ),
      chestCircumferenceCm: pickDouble(
        json['chest_circumference_cm'] ?? json['perimetro_pecho_cm'],
      ),
      confidence: pickDouble(json['confidence'] ?? json['confianza']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  bool get hasAnyMeasurement =>
      waistCircumferenceCm != null ||
      armWidthCm != null ||
      hipCircumferenceCm != null ||
      chestCircumferenceCm != null;
}
