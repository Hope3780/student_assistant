/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: model
*/


class AppUser {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final int? studentYear;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    this.studentYear,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      fullName: json['full_name'] ?? '',
      studentYear: json['student_year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'full_name': fullName,
      'student_year': studentYear,
    };
  }
}