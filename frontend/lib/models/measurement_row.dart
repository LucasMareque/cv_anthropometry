/// Una fila de la tabla de predicciones devuelta por el backend.
class MeasurementRow {
  const MeasurementRow({
    required this.key,
    required this.label,
    required this.valueCm,
    this.unit = 'cm',
    this.order = 0,
  });

  final String key;
  final String label;
  final double valueCm;
  final String unit;
  final int order;

  factory MeasurementRow.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    return MeasurementRow(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ??
          json['label_es']?.toString() ??
          json['key']?.toString() ??
          '',
      valueCm: parseValue(json['value_cm'] ?? json['value']),
      unit: json['unit']?.toString() ?? 'cm',
      order: json['order'] is int ? json['order'] as int : int.tryParse('${json['order']}') ?? 0,
    );
  }
}
