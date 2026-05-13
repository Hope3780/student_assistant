import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/student_application_viewmodel.dart';
import '../models/module_application.dart';
import '../services/storage_service.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: view
*/

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _module1NameController = TextEditingController();
  final _module2NameController = TextEditingController();
  
  int _currentYearOfStudy = 1;
  bool _eligibilityConfirmed = false;
  String _academicLevel1 = 'first-year';
  String _academicLevel2 = 'first-year';
  bool _meetsRequirements1 = false;
  bool _meetsRequirements2 = false;
  bool _includeSecondModule = false;
  File? _supportingDocument;
  
  final List<String> _academicLevels = ['first-year', 'second-year', 'third-year'];
  
  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }
  
  void _loadExistingData() {
    final studentVM = Provider.of<StudentApplicationViewModel>(context, listen: false);
    final existingApp = studentVM.application;
    
    if (existingApp != null && existingApp.status == 'pending') {
      _currentYearOfStudy = existingApp.currentYearOfStudy;
      _eligibilityConfirmed = existingApp.eligibilityConfirmed;
      if (existingApp.modules.isNotEmpty) {
        _academicLevel1 = existingApp.modules[0].academicLevel;
        _module1NameController.text = existingApp.modules[0].moduleName;
        _meetsRequirements1 = existingApp.modules[0].meetsRequirements;
        
        if (existingApp.modules.length > 1) {
          _includeSecondModule = true;
          _academicLevel2 = existingApp.modules[1].academicLevel;
          _module2NameController.text = existingApp.modules[1].moduleName;
          _meetsRequirements2 = existingApp.modules[1].meetsRequirements;
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final studentVM = Provider.of<StudentApplicationViewModel>(context);
    final existingApp = studentVM.application;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(existingApp == null ? 'New Application' : 'Edit Application'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year of Study
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Academic Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _currentYearOfStudy,
                            decoration: const InputDecoration(
                              labelText: 'Year of Study',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.school),
                            ),
                            items: [1, 2, 3].map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text('Year $year'),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _currentYearOfStudy = value!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Module 1 (Required)
                  _buildModuleSection(
                    title: 'Module 1 (Required)',
                    academicLevel: _academicLevel1,
                    onAcademicLevelChanged: (String? value) => setState(() {
                      if (value != null) _academicLevel1 = value;
                    }),
                    moduleNameController: _module1NameController,
                    meetsRequirements: _meetsRequirements1,
                    onMeetsRequirementsChanged: (value) => setState(() => _meetsRequirements1 = value),
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Module 2 (Optional)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: const Text(
                              'Apply for second module (Optional)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            value: _includeSecondModule,
                            onChanged: (value) => setState(() => _includeSecondModule = value ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (_includeSecondModule) ...[
                            const SizedBox(height: 8),
                            _buildModuleSection(
                              title: 'Module 2 Details',
                              academicLevel: _academicLevel2,
                              onAcademicLevelChanged: (String? value) => setState(() {
                                if (value != null) _academicLevel2 = value;
                              }),
                              moduleNameController: _module2NameController,
                              meetsRequirements: _meetsRequirements2,
                              onMeetsRequirementsChanged: (value) => setState(() => _meetsRequirements2 = value),
                              isRequired: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Eligibility
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Confirm Eligibility',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          CheckboxListTile(
                            title: const Text(
                              'I confirm that I meet the eligibility requirements for this position',
                            ),
                            value: _eligibilityConfirmed,
                            onChanged: (value) => setState(() => _eligibilityConfirmed = value ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Supporting Document (OPTIONAL NOW)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Supporting Documentation (Optional)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _pickDocument(),
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Upload Document'),
                                ),
                              ),
                              if (_supportingDocument != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _supportingDocument = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                          if (_supportingDocument != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Selected: ${_supportingDocument!.path.split('/').last}',
                                      style: const TextStyle(fontSize: 12, color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'No document selected (optional)',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                          if (studentVM.application?.supportingDocUrl != null && _supportingDocument == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Current document uploaded',
                                style: TextStyle(fontSize: 12, color: Colors.blue),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: studentVM.isLoading ? null : () => _submitForm(context, studentVM),
                      child: studentVM.isLoading
                          ? const CircularProgressIndicator()
                          : Text(existingApp == null ? 'Submit Application' : 'Update Application'),
                    ),
                  ),
                  
                  if (studentVM.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        studentVM.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (studentVM.isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Uploading document...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildModuleSection({
    required String title,
    required String academicLevel,
    required Function(String?) onAcademicLevelChanged,
    required TextEditingController moduleNameController,
    required bool meetsRequirements,
    required Function(bool) onMeetsRequirementsChanged,
    required bool isRequired,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: academicLevel,
              decoration: const InputDecoration(
                labelText: 'Academic Level',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.menu_book),
              ),
              items: _academicLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.replaceAll('-', ' ')),
                );
              }).toList(),
              onChanged: onAcademicLevelChanged,
              validator: isRequired ? (value) => value == null ? 'Required' : null : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: moduleNameController,
              decoration: const InputDecoration(
                labelText: 'Module Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              validator: isRequired
                  ? (value) => value == null || value.isEmpty ? 'Module name is required' : null
                  : null,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Meets minimum requirements for this module'),
              value: meetsRequirements,
              onChanged: (value) => onMeetsRequirementsChanged(value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickDocument() async {
    final file = await StorageService.pickDocument(ImageSource.gallery);
    if (file != null) {
      setState(() {
        _supportingDocument = file;
      });
    }
  }
  
  Future<void> _submitForm(BuildContext context, StudentApplicationViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_eligibilityConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm eligibility')),
      );
      return;
    }
    
    // REMOVED: Document validation - now optional
    
    // Validate module names
    if (_module1NameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter module name for Module 1')),
      );
      return;
    }
    
    final modules = <ModuleApplication>[
      ModuleApplication(
        academicLevel: _academicLevel1,
        moduleName: _module1NameController.text.trim(),
        meetsRequirements: _meetsRequirements1,
      ),
    ];
    
    if (_includeSecondModule && _module2NameController.text.trim().isNotEmpty) {
      if (_module2NameController.text.trim() == _module1NameController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot apply for the same module twice')),
        );
        return;
      }
      modules.add(ModuleApplication(
        academicLevel: _academicLevel2,
        moduleName: _module2NameController.text.trim(),
        meetsRequirements: _meetsRequirements2,
      ));
    }
    
    bool success;
    if (vm.application == null) {
      success = await vm.submitApplication(
        currentYearOfStudy: _currentYearOfStudy,
        eligibilityConfirmed: _eligibilityConfirmed,
        supportingDocument: _supportingDocument, // Can be null
        modules: modules,
      );
    } else {
      success = await vm.updateApplication(
        currentYearOfStudy: _currentYearOfStudy,
        eligibilityConfirmed: _eligibilityConfirmed,
        supportingDocument: _supportingDocument, // Can be null
        modules: modules,
      );
    }
    
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.application == null ? 'Application submitted successfully!' : 'Application updated successfully!'),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Failed to submit application')),
      );
    }
  }
}