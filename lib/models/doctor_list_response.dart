import 'package:medapp/models/doctor.dart';

class DoctorListResponse {
  final List<Doctor> items;
  final int total;
  final int page;
  final int pages;

  DoctorListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory DoctorListResponse.fromJson(Map<String, dynamic> json) {
    return DoctorListResponse(
      items:
          (json['items'] as List).map((item) => Doctor.fromJson(item)).toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pages: json['pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((doctor) => doctor.toJson()).toList(),
      'total': total,
      'page': page,
      'pages': pages,
    };
  }
}
