import 'dart:io';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../models/application.dart';
import '../models/module_application.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: viewmodel
*/

class StudentApplicationViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final StorageService _storageService = StorageService();
  
  Application? _application;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  String? _currentUserId;

  Application? get application => _application;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  bool get hasApplication => _application != null;
  bool get canEdit => _application != null && _application!.status == 'pending';

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    loadApplication();
  }

  Future<void> loadApplication() async {
    if (_currentUserId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _application = await _supabaseService.getStudentApplication(_currentUserId!);
    } catch (e) {
      _errorMessage = 'Failed to load application: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitApplication({
  required int currentYearOfStudy,
  required bool eligibilityConfirmed,
  required File? supportingDocument, // Made nullable
  required List<ModuleApplication> modules,
}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    String? docUrl;
    
    // Only upload if document is provided
    if (supportingDocument != null) {
      _isUploading = true;
      notifyListeners();
      
      print('Uploading document...');
      docUrl = await _storageService.uploadSupportingDocument(
        _currentUserId!,
        supportingDocument,
      );
      
      if (docUrl == null) {
        _errorMessage = 'Failed to upload supporting document. You can submit without it.';
        // Don't return false - allow submission without document
        // Just warn the user
        print('Warning: Document upload failed, but continuing without it');
      }
      
      _isUploading = false;
    } else {
      print('No document provided, submitting without supporting document');
    }

    print('Creating application...');
    await _supabaseService.createApplication(
      studentId: _currentUserId!,
      currentYearOfStudy: currentYearOfStudy,
      eligibilityConfirmed: eligibilityConfirmed,
      supportingDocUrl: docUrl, // Can be null
      modules: modules,
    );

    await loadApplication();
    print('Application submitted successfully');
    return true;
  } catch (e) {
    _errorMessage = 'Failed to submit application: ${e.toString()}';
    print('Submit error: $e');
    return false;
  } finally {
    _isLoading = false;
    _isUploading = false;
    notifyListeners();
  }
}

Future<bool> updateApplication({
  required int currentYearOfStudy,
  required bool eligibilityConfirmed,
  required File? supportingDocument, // Made nullable
  required List<ModuleApplication> modules,
}) async {
  if (!canEdit) {
    _errorMessage = 'Cannot update application that is not pending';
    notifyListeners();
    return false;
  }

  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    String? docUrl = _application!.supportingDocUrl;
    
    if (supportingDocument != null) {
      _isUploading = true;
      notifyListeners();
      
      // Delete old document if exists
      if (_application!.supportingDocUrl != null && _application!.supportingDocUrl!.isNotEmpty) {
        await _storageService.deleteSupportingDocument(_application!.supportingDocUrl!);
      }
      
      docUrl = await _storageService.uploadSupportingDocument(
        _currentUserId!,
        supportingDocument,
      );
      
      if (docUrl == null) {
        _errorMessage = 'Failed to upload new document, keeping existing one';
        docUrl = _application!.supportingDocUrl; // Keep old one
      }
      
      _isUploading = false;
    }

    await _supabaseService.updateApplication(
      applicationId: _application!.id,
      currentYearOfStudy: currentYearOfStudy,
      eligibilityConfirmed: eligibilityConfirmed,
      supportingDocUrl: docUrl,
      modules: modules,
    );

    await loadApplication();
    return true;
  } catch (e) {
    _errorMessage = 'Failed to update application: ${e.toString()}';
    return false;
  } finally {
    _isLoading = false;
    _isUploading = false;
    notifyListeners();
  }
}

  Future<bool> deleteApplication() async {
    if (!canEdit) {
      _errorMessage = 'Cannot delete application that is not pending';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete supporting document if exists
      if (_application!.supportingDocUrl != null && _application!.supportingDocUrl!.isNotEmpty) {
        await _storageService.deleteSupportingDocument(_application!.supportingDocUrl!);
      }
      
      await _supabaseService.deleteApplication(_application!.id);
      _application = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}