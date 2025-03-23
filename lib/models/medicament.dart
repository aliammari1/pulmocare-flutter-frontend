class Medicament {
  final String name;
  final String? usage;
  final String? dosage;
  final String? posologie;
  final String? laboratoire;
  final String? route; // Added field
  final String? warning; // Added field

  Medicament({
    required this.name,
    this.usage,
    this.dosage,
    this.posologie,
    this.laboratoire,
    this.route,
    this.warning,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'usage': usage,
      'dosage': dosage,
      'posologie': posologie,
      'laboratoire': laboratoire,
      'route': route,
      'warning': warning,
    };
  }

  factory Medicament.fromJson(Map<String, dynamic> json) {
    return Medicament(
      name: json['name'] ?? '',
      usage: json['usage'],
      dosage: json['dosage']?? '',
      posologie: json['posologie'],
      laboratoire: json['laboratoire'],
      route: json['route'],
      warning: json['warning'],
    );
  }
}
