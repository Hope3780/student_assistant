import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';
import '../models/module_application.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: service
*/

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== AUTHENTICATION METHODS ====================
  
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> createUserProfile(Map<String, dynamic> profile) async {
    await _supabase.from('profiles').insert(profile);
  }

  // ==================== APPLICATION METHODS ====================

  Future<Application?> getStudentApplication(String studentId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select('*, module_applications(*)')
          .eq('student_id', studentId)
          .maybeSingle();
      
      if (response == null) return null;
      return Application.fromJson(response);
    } catch (e) {
      print('Get application error: $e');
      return null;
    }
  }

  Future<String> createApplication({
    required String studentId,
    required int currentYearOfStudy,
    required bool eligibilityConfirmed,
    required String? supportingDocUrl,
    required List<ModuleApplication> modules,
  }) async {
    try {
      print('Creating application for student: $studentId');
      
      // Create application
      final appResponse = await _supabase.from('applications').insert({
        'student_id': studentId,
        'current_year_of_study': currentYearOfStudy,
        'eligibility_confirmed': eligibilityConfirmed,
        'supporting_doc_url': supportingDocUrl,
        'status': 'pending',
      }).select();
      
      if (appResponse.isEmpty) {
        throw Exception('Failed to create application');
      }
      
      final applicationId = appResponse[0]['id'];
      print('Application created with ID: $applicationId');

      // Create modules
      for (var module in modules) {
        await _supabase.from('module_applications').insert({
          'application_id': applicationId,
          'academic_level': module.academicLevel,
          'module_name': module.moduleName,
          'meets_requirements': module.meetsRequirements,
        });
        print('Module added: ${module.moduleName}');
      }

      return applicationId;
    } catch (e) {
      print('Create application error: $e');
      rethrow;
    }
  }

  Future<void> updateApplication({
    required String applicationId,
    required int currentYearOfStudy,
    required bool eligibilityConfirmed,
    required String? supportingDocUrl,
    required List<ModuleApplication> modules,
  }) async {
    try {
      print('Updating application: $applicationId');
      
      // Update application
      await _supabase.from('applications').update({
        'current_year_of_study': currentYearOfStudy,
        'eligibility_confirmed': eligibilityConfirmed,
        'supporting_doc_url': supportingDocUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);

      // Delete existing modules
      await _supabase
          .from('module_applications')
          .delete()
          .eq('application_id', applicationId);

      // Create new modules
      for (var module in modules) {
        await _supabase.from('module_applications').insert({
          'application_id': applicationId,
          'academic_level': module.academicLevel,
          'module_name': module.moduleName,
          'meets_requirements': module.meetsRequirements,
        });
      }
      
      print('Application updated successfully');
    } catch (e) {
      print('Update application error: $e');
      rethrow;
    }
  }

  Future<void> deleteApplication(String applicationId) async {
    try {
      await _supabase
          .from('module_applications')
          .delete()
          .eq('application_id', applicationId);
      
      await _supabase
          .from('applications')
          .delete()
          .eq('id', applicationId);
          
      print('Application deleted: $applicationId');
    } catch (e) {
      print('Delete application error: $e');
      rethrow;
    }
  }

  // ==================== ADMIN METHODS ====================

  Future<List<Application>> getAllApplications() async {
    try {
      final response = await _supabase
          .from('applications')
          .select('*, module_applications(*)')
          .order('created_at', ascending: false);
      
      return response.map((json) => Application.fromJson(json)).toList();
    } catch (e) {
      print('Get all applications error: $e');
      return [];
    }
  }

  // Update application status
Future<void> updateApplicationStatus(String applicationId, String status) async {
  try {
    await _supabase.from('applications').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', applicationId);
    
    print('✅ Application $applicationId status updated to $status');
  } catch (e) {
    print('❌ Error updating status: $e');
    rethrow;
  }
}
}
