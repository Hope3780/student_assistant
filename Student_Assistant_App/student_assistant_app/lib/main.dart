import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/student_application_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'views/auth_wrapper.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: main
*/


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ibbnqqydvfrdeofjtfhf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliYm5xcXlkdmZyZGVvZmp0ZmhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTMyNTksImV4cCI6MjA5NDE4OTI1OX0.YwF7pMv10zMFsJsEuIDmz4LsdbfzSsEBKhVOXi9xeGA',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Simple providers without dependencies
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StudentApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          // Update other VMs when auth changes
          final studentVM = Provider.of<StudentApplicationViewModel>(context, listen: false);
          final adminVM = Provider.of<AdminViewModel>(context, listen: false);
          
          if (authVM.currentUserId != null) {
            studentVM.setCurrentUser(authVM.currentUserId!);
            adminVM.setCurrentUser(authVM.currentUserId!);
          }
          
          return MaterialApp(
            title: 'Student Assistant System',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}