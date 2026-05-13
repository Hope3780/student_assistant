/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: model
*/

class ModuleApplication {
  final String? id;
  final String? applicationId;
  final String academicLevel;
  final String moduleName;
  final bool meetsRequirements;

  ModuleApplication({
    this.id,
    this.applicationId,
    required this.academicLevel,
    required this.moduleName,
    required this.meetsRequirements,
  });

  factory ModuleApplication.fromJson(Map<String, dynamic> json) {
    return ModuleApplication(
      id: json['id'],
      applicationId: json['application_id'],
      academicLevel: json['academic_level'],
      moduleName: json['module_name'],
      meetsRequirements: json['meets_requirements'],
    );
  }

Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'academic_level': academicLevel,
      'module_name': moduleName,
      'meets_requirements': meetsRequirements,
    };
  }

  ModuleApplication copyWith({
    String? id,
    String? applicationId,
    String? academicLevel,
    String? moduleName,
    bool? meetsRequirements,
  }) {
    return ModuleApplication(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      academicLevel: academicLevel ?? this.academicLevel,
      moduleName: moduleName ?? this.moduleName,
      meetsRequirements: meetsRequirements ?? this.meetsRequirements,
    );
  }
}
