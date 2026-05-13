import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/app_user.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: viewmodel
*/

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  AppUser? _currentUser;
  String? _userRole;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  String? get currentUserId => _currentUser?.id;
  String? get currentUserEmail => _currentUser?.email;
  
  // Check if current user is admin
  bool get isAdmin => _userRole == 'admin';
  
  // Check if current user is student
  bool get isStudent => _userRole == 'student';

  // Sign Up - STUDENTS ONLY
  Future<bool> signUp(String email, String password, String fullName, int studentYear) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signUp(email, password, fullName);
      
      if (response.user != null) {
        // Create profile - ALWAYS STUDENT
        await _supabaseService.createUserProfile({
          'id': response.user!.id,
          'email': email,
          'role': 'student', // Always student on signup
          'full_name': fullName,
          'student_year': studentYear,
        });
        
        // Auto login after signup
        return await signIn(email, password);
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign In
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signIn(email, password);
      
      if (response.user != null) {
        final userProfile = await _supabaseService.getUserProfile(response.user!.id);
        
        if (userProfile != null) {
          _currentUser = AppUser.fromJson(userProfile);
          _userRole = _currentUser?.role;
          print('User logged in with role: $_userRole');
          notifyListeners();
          return true;
        }
      }
      _errorMessage = 'Invalid credentials';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabaseService.signOut();
    _currentUser = null;
    _userRole = null;
    notifyListeners();
  }

  // Load current user
  Future<void> loadCurrentUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final userProfile = await _supabaseService.getUserProfile(session.user.id);
      if (userProfile != null) {
        _currentUser = AppUser.fromJson(userProfile);
        _userRole = _currentUser?.role;
        notifyListeners();
      }
    }
  }
}