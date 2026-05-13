import 'package:flutter/material.dart';
import '../models/application.dart';
//import '../models/module_application.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: view
*/

class ApplicationDetailScreen extends StatelessWidget {
  final Application application;
  
  const ApplicationDetailScreen({super.key, required this.application});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildModulesCard(),
            const SizedBox(height: 16),
            _buildDocumentCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Application Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(application.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(application.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Year of Study', 'Year ${application.currentYearOfStudy}'),
            const SizedBox(height: 8),
            _buildInfoRow('Eligibility Confirmed', application.eligibilityConfirmed ? 'Yes' : 'No'),
            const SizedBox(height: 8),
            _buildInfoRow('Submitted', _formatDate(application.createdAt)),
            const SizedBox(height: 8),
            _buildInfoRow('Last Updated', _formatDate(application.updatedAt)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModulesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Module Applications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${application.modules.length} module(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...application.modules.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final module = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Module $index',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildModuleRow('Academic Level', _formatAcademicLevel(module.academicLevel)),
                    _buildModuleRow('Module Name', module.moduleName),
                    _buildModuleRow('Meets Requirements', module.meetsRequirements ? 'Yes' : 'No'),
                    if (index < application.modules.length) const Divider(),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDocumentCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attachment, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Supporting Document',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (application.supportingDocUrl != null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.description, size: 50, color: Colors.blue),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _viewDocument(),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Document'),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: Text(
                  'No document uploaded',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Widget _buildModuleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
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
  
  String _formatAcademicLevel(String level) {
    return level.replaceAll('-', ' ').toUpperCase();
  }
  
  void _viewDocument() {
    // In a real app, you would use url_launcher to open the document
    // For now, we'll just show a snackbar
    // You can add url_launcher dependency and implement:
    // launchUrl(Uri.parse(application.supportingDocUrl!));
  }
}