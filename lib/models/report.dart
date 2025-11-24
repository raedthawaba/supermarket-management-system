class Report {
  final String id;
  final String title;
  final String type; // 'daily', 'weekly', 'monthly', 'yearly', 'custom'
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final String generatedBy;
  final String? notes;

  const Report({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.generatedAt,
    required this.generatedBy,
    this.notes,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'data': data,
      'generatedAt': generatedAt,
      'generatedBy': generatedBy,
      'notes': notes,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case 'daily':
        return 'يومي';
      case 'weekly':
        return 'أسبوعي';
      case 'monthly':
        return 'شهري';
      case 'yearly':
        return 'سنوي';
      case 'custom':
        return 'مخصص';
      default:
        return 'غير محدد';
    }
  }
}