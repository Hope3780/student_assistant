import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/application.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: 
*/


class AdminViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Application> _applications = [];
  List<Application> _filteredApplications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _statusFilter;
  String? _moduleFilter;
  bool _isUpdating = false; // Track status update

  List<Application> get applications => _filteredApplications;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;
  String? get moduleFilter => _moduleFilter;

  void setCurrentUser(String userId) {
    loadApplications();
  }

  Future<void> loadApplications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _applications = await _supabaseService.getAllApplications();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load applications: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredApplications = _applications.where((app) {
      if (_statusFilter != null && app.status != _statusFilter) {
        return false;
      }
      if (_moduleFilter != null && _moduleFilter!.isNotEmpty) {
        bool hasModule = app.modules.any((m) => 
            m.moduleName.toLowerCase().contains(_moduleFilter!.toLowerCase()));
        if (!hasModule) return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    _applyFilters();
  }

  void setModuleFilter(String? module) {
    _moduleFilter = module;
    _applyFilters();
  }

  void clearFilters() {
    _statusFilter = null;
    _moduleFilter = null;
    _applyFilters();
  }

  // Update application status (Approve/Reject)
  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.updateApplicationStatus(applicationId, status);
      
      // Update local list
      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        final updatedApp = Application(
          id: _applications[index].id,
          studentId: _applications[index].studentId,
          currentYearOfStudy: _applications[index].currentYearOfStudy,
          eligibilityConfirmed: _applications[index].eligibilityConfirmed,
          supportingDocUrl: _applications[index].supportingDocUrl,
          status: status, // Updated status
          createdAt: _applications[index].createdAt,
          updatedAt: DateTime.now(),
          modules: _applications[index].modules,
        );
        _applications[index] = updatedApp;
      }
      
      _applyFilters(); // Refresh filtered list
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status: ${e.toString()}';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Bulk update multiple applications
  Future<Map<String, bool>> bulkUpdateStatus(List<String> applicationIds, String status) async {
    final results = <String, bool>{};
    _isUpdating = true;
    notifyListeners();

    for (var id in applicationIds) {
      final success = await updateApplicationStatus(id, status);
      results[id] = success;
    }

    _isUpdating = false;
    notifyListeners();
    return results;
  }

  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.deleteApplication(applicationId);
      _applications.removeWhere((app) => app.id == applicationId);
      _applyFilters();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get statistics
  Map<String, int> getStatistics() {
    return {
      'total': _applications.length,
      'pending': _applications.where((a) => a.status == 'pending').length,
      'approved': _applications.where((a) => a.status == 'approved').length,
      'rejected': _applications.where((a) => a.status == 'rejected').length,
    };
  }
}