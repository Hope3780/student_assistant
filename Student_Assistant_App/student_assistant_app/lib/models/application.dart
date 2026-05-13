import 'module_application.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: model
*/


class Application {
  final String id;
  final String studentId;
  final int currentYearOfStudy;
  final bool eligibilityConfirmed;
  final String? supportingDocUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ModuleApplication> modules;

  Application({
    required this.id,
    required this.studentId,
    required this.currentYearOfStudy,
    required this.eligibilityConfirmed,
    this.supportingDocUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.modules,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    var modulesList = <ModuleApplication>[];
    if (json['module_applications'] != null) {
      modulesList = (json['module_applications'] as List)
          .map((m) => ModuleApplication.fromJson(m))
          .toList();
    }

    return Application(
      id: json['id'],
      studentId: json['student_id'],
      currentYearOfStudy: json['current_year_of_study'],
      eligibilityConfirmed: json['eligibility_confirmed'],
      supportingDocUrl: json['supporting_doc_url'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      modules: modulesList,
    );
  }
}