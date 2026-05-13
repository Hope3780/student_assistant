import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/application.dart';
import 'unauthorized_screen.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: view
*/

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final Set<String> _selectedApplications = {}; // For bulk actions
  bool _isBulkMode = false;

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    
    // Security check - redirect if not admin
    if (!authVM.isAdmin) {
      return const UnauthorizedScreen();
    }
    
    final adminVM = Provider.of<AdminViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.red[700],
        actions: [
          // Bulk actions button
          if (_isBulkMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isBulkMode = false;
                  _selectedApplications.clear();
                });
              },
              tooltip: 'Exit bulk mode',
            )
          else
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                setState(() {
                  _isBulkMode = true;
                });
              },
              tooltip: 'Bulk actions',
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, adminVM),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminVM.loadApplications(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authVM.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          _buildStatsRow(adminVM),
          
          // Bulk actions bar (visible when in bulk mode)
          if (_isBulkMode && _selectedApplications.isNotEmpty)
            _buildBulkActionsBar(adminVM),
          
          // Applications list
          Expanded(
            child: _buildApplicationsList(adminVM),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AdminViewModel adminVM) {
    final stats = adminVM.getStatistics();
    
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total', stats['total']!, Colors.blue),
          _buildStatCard('Pending', stats['pending']!, Colors.orange, onTap: () {
            adminVM.setStatusFilter('pending');
          }),
          _buildStatCard('Approved', stats['approved']!, Colors.green, onTap: () {
            adminVM.setStatusFilter('approved');
          }),
          _buildStatCard('Rejected', stats['rejected']!, Colors.red, onTap: () {
            adminVM.setStatusFilter('rejected');
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionsBar(AdminViewModel adminVM) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_selectedApplications.length} selected',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: adminVM.isUpdating
                    ? null
                    : () => _bulkUpdateStatus(adminVM, 'approved'),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Approve All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: adminVM.isUpdating
                    ? null
                    : () => _bulkUpdateStatus(adminVM, 'rejected'),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Reject All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(AdminViewModel adminVM) {
    if (adminVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (adminVM.applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No applications found',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (adminVM.statusFilter != null || (adminVM.moduleFilter != null && adminVM.moduleFilter!.isNotEmpty))
              TextButton(
                onPressed: () => adminVM.clearFilters(),
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => adminVM.loadApplications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: adminVM.applications.length,
        itemBuilder: (context, index) {
          final app = adminVM.applications[index];
          return _buildApplicationCard(context, adminVM, app);
        },
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, AdminViewModel vm, Application app) {
    Color statusColor;
    switch (app.status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: _isBulkMode
            ? Checkbox(
                value: _selectedApplications.contains(app.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedApplications.add(app.id);
                    } else {
                      _selectedApplications.remove(app.id);
                    }
                  });
                },
              )
            : CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.2),
                child: Icon(Icons.person, color: statusColor),
              ),
        title: Text(
          'Application #${app.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student ID: ${app.studentId.substring(0, 8)}...'),
            const SizedBox(height: 4),
            Text(
              'Modules: ${app.modules.map((m) => m.moduleName).join(', ')}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            app.status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Application details
                _buildDetailRow('Year of Study', 'Year ${app.currentYearOfStudy}'),
                const SizedBox(height: 8),
                _buildDetailRow('Eligibility', app.eligibilityConfirmed ? 'Confirmed' : 'Not Confirmed'),
                const SizedBox(height: 8),
                _buildDetailRow('Submitted', _formatDate(app.createdAt)),
                const SizedBox(height: 8),
                _buildDetailRow('Last Updated', _formatDate(app.updatedAt)),
                const SizedBox(height: 16),
                
                // Module details
                const Text(
                  'Module Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...app.modules.map((module) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    children: [
                      Icon(
                        module.meetsRequirements ? Icons.check_circle : Icons.warning,
                        size: 16,
                        color: module.meetsRequirements ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${module.moduleName} (${_formatAcademicLevel(module.academicLevel)}) - '
                          '${module.meetsRequirements ? "Meets requirements" : "Doesn't meet requirements"}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
                
                // Supporting document
                if (app.supportingDocUrl != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _viewDocument(app.supportingDocUrl!),
                    icon: const Icon(Icons.attachment),
                    label: const Text('View Supporting Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Status update buttons (only for pending applications)
                if (app.status == 'pending') ...[
                  const Text(
                    'Update Application Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: vm.isUpdating
                              ? null
                              : () => _updateStatus(context, vm, app.id, 'approved'),
                          icon: vm.isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: vm.isUpdating
                              ? null
                              : () => _updateStatus(context, vm, app.id, 'rejected'),
                          icon: vm.isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context, vm, app.id),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Show for already approved/rejected applications
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This application has been ${app.status}.',
                            style: TextStyle(color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatAcademicLevel(String level) {
    return level.replaceAll('-', ' ').toUpperCase();
  }

  Future<void> _updateStatus(BuildContext context, AdminViewModel vm, String appId, String status) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(status == 'approved' ? 'Approve Application' : 'Reject Application'),
        content: Text(
          'Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} this application?\n\n'
          'This action can be changed later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved' ? Colors.green : Colors.red,
            ),
            child: Text(status == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await vm.updateApplicationStatus(appId, status);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Application ${status == 'approved' ? 'approved' : 'rejected'} successfully!'
                  : 'Failed to update status: ${vm.errorMessage}',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkUpdateStatus(AdminViewModel vm, String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bulk ${status == 'approved' ? 'Approve' : 'Reject'}'),
        content: Text(
          'Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} '
          '${_selectedApplications.length} selected application(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved' ? Colors.green : Colors.red,
            ),
            child: Text(status == 'approved' ? 'Approve All' : 'Reject All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final results = await vm.bulkUpdateStatus(_selectedApplications.toList(), status);
      
      final successCount = results.values.where((s) => s).length;
      final failCount = results.values.where((s) => !s).length;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Updated $successCount applications successfully'
              '${failCount > 0 ? ', $failCount failed' : ''}',
            ),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          ),
        );
        
        setState(() {
          _isBulkMode = false;
          _selectedApplications.clear();
        });
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, AdminViewModel vm, String appId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text('Are you sure you want to delete this application? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.deleteApplication(appId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Application deleted successfully' : 'Failed to delete'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, AdminViewModel vm) {
    final moduleFilterController = TextEditingController(text: vm.moduleFilter);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Applications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: vm.statusFilter,
              hint: const Text('Filter by status'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['', 'pending', 'approved', 'rejected'].map((status) {
                return DropdownMenuItem(
                  value: status.isEmpty ? null : status,
                  child: Text(status.isEmpty ? 'All' : status.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                vm.setStatusFilter(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: moduleFilterController,
              decoration: const InputDecoration(
                labelText: 'Filter by module name',
                border: OutlineInputBorder(),
                hintText: 'Enter module name',
              ),
              onSubmitted: (value) {
                vm.setModuleFilter(value);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              vm.clearFilters();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
          ElevatedButton(
            onPressed: () {
              vm.setModuleFilter(moduleFilterController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _viewDocument(String url) {
    // In production, use url_launcher package
    // launchUrl(Uri.parse(url));
  }
}