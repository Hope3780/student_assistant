import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

/* 
 * Student Numbers : 224031692,220044608,223026861,222002087,224054460,224066331,224047638
 * Student Names : Bongani Mmakola,Mpilonhle Madlala,Mpho Kalake,Hope Khosa,Tshegofatso Mhlafu,Mfutho Zungu,Cebisa Zikalala
 * Question: service
*/

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'applications';

  // Pick image from gallery or camera - NO SIZE RESTRICTIONS
  static Future<File?> pickDocument(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        // NO maxWidth, NO maxHeight, NO imageQuality - removed all restrictions
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Upload supporting document to Supabase Storage - NO SIZE CHECK
  Future<String?> uploadSupportingDocument(String studentId, File documentFile) async {
    try {
      print('Starting upload for student: $studentId');
      
      // Check if file exists
      if (!await documentFile.exists()) {
        print('File does not exist');
        return null;
      }
      
      // NO file size check - removed completely
      
      // Create unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = documentFile.path.split('.').last;
      final fileName = '$studentId/$timestamp.$fileExt';
      print('File name: $fileName');
      
      // Read file bytes
      final bytes = await documentFile.readAsBytes();
      print('File bytes length: ${bytes.length}');
      
      // Upload to bucket
      await _supabase.storage.from(_bucketName).uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      // Get public URL
      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      print('Upload successful: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  // Delete supporting document
  Future<bool> deleteSupportingDocument(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return true;
      
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(_bucketName);
      
      if (bucketIndex != -1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from(_bucketName).remove([filePath]);
        print('Deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }
}
