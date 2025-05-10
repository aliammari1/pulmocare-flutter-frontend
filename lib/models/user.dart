enum UserRole {
  doctor,
  patient,
  radiologist,
  admin,
}

class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? profilePicture;
  UserRole? role;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.profilePicture,
    this.role,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    profilePicture = json['profile_picture'];
    role = _parseUserRole(json['role']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['profile_picture'] = profilePicture;
    data['role'] = role?.toString().split('.').last;
    return data;
  }

  static UserRole? _parseUserRole(String? role) {
    if (role == null) return null;
    switch (role.toLowerCase()) {
      case 'doctor':
        return UserRole.doctor;
      case 'patient':
        return UserRole.patient;
      case 'radiologist':
        return UserRole.radiologist;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }
}
