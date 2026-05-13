import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_application_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'application_form_screen.dart';
import 'application_detail_screen.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: view
*/

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentVM = Provider.of<StudentApplicationViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => studentVM.loadApplication(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authVM.signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => studentVM.loadApplication(),
        child: studentVM.isLoading
            ? const Center(child: CircularProgressIndicator())
            : studentVM.hasApplication
                ? _buildApplicationList(context, studentVM)
                : _buildEmptyState(context),
      ),
      floatingActionButton: !studentVM.hasApplication
          ? FloatingActionButton(
              onPressed: () => _navigateToForm(context, null),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildApplicationList(BuildContext context, StudentApplicationViewModel vm) {
    final app = vm.application!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          child: InkWell(
            onTap: () => _navigateToDetail(context, app),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Student Assistant Application',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(app.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                app.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(app.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoRow('Year of Study', 'Year ${app.currentYearOfStudy}'),
                  _buildInfoRow('Submitted', _formatDate(app.createdAt)),
                  _buildInfoRow('Modules', '${app.modules.length} module(s)'),
                  if (vm.canEdit)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _navigateToForm(context, app),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _showDeleteDialog(context, vm),
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Delete'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Application Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to submit your application',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _navigateToForm(BuildContext context, app) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ApplicationFormScreen()),
    // ignore: use_build_context_synchronously
    ).then((_) => Provider.of<StudentApplicationViewModel>(context, listen: false).loadApplication());
  }

  void _navigateToDetail(BuildContext context, app) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApplicationDetailScreen(application: app)),
    );
  }

  void _showDeleteDialog(BuildContext context, StudentApplicationViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete your application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.deleteApplication();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application deleted successfully')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.errorMessage ?? 'Failed to delete')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
