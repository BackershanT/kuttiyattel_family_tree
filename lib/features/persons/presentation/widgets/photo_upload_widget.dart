import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

/// Photo upload widget with camera/gallery selection and Supabase Storage upload
class PhotoUploadWidget extends StatefulWidget {
  final String? currentPhotoUrl;
  final ValueChanged<String?> onPhotoUploaded;
  final ValueChanged<bool>? onUploadingChanged;
  final bool isLoading;

  const PhotoUploadWidget({
    super.key,
    this.currentPhotoUrl,
    required this.onPhotoUploaded,
    this.onUploadingChanged,
    this.isLoading = false,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  File? _localFile;
  Uint8List? _imageBytes; // For web compatibility
  bool _isUploading = false;
  String? _uploadedPhotoUrl;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Read bytes for web compatibility
        final bytes = await image.readAsBytes();
        final extension = image.name.split('.').last;
        
        setState(() {
          // Store bytes for web display
          _imageBytes = bytes; 
          // We can't use File(image.path) on web safely, 
          // but we can set it to null or a placeholder if needed.
          // Since we use _imageBytes for display, we don't strictly need _localFile.
          _localFile = null; 
        });
        await _uploadToSupabase(bytes, extension);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _uploadToSupabase(Uint8List fileBytes, String fileExtension) async {
    setState(() {
      _isUploading = true;
    });
    widget.onUploadingChanged?.call(true);

    try {
      // Generate unique filename
      final uuid = const Uuid().v4();
      final fileName = 'person_$uuid.$fileExtension';

      print('═══════════════════════════════════════════════════════════');
      print('PHOTO UPLOAD: STARTING');
      print('Bucket: PHOTOS');
      print('FileName: $fileName');
      print('Size: ${fileBytes.length} bytes');
      print('═══════════════════════════════════════════════════════════');

      // Upload to Supabase Storage bucket 'PHOTOS'
      await Supabase.instance.client.storage
          .from('PHOTOS')
          .uploadBinary(
            fileName, 
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg', // Default to jpeg, or dynamic based on extension
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('PHOTOS')
          .getPublicUrl(fileName);

      print('UPLOAD SUCCESSFUL');
      print('Public URL: $publicUrl');
      print('═══════════════════════════════════════════════════════════');

      setState(() {
        _uploadedPhotoUrl = publicUrl;
        _isUploading = false;
      });
      widget.onUploadingChanged?.call(false);

      widget.onPhotoUploaded(publicUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('UPLOAD FAILED: $e');
      print('═══════════════════════════════════════════════════════════');

      setState(() {
        _isUploading = false;
      });
      widget.onUploadingChanged?.call(false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (widget.currentPhotoUrl != null || _uploadedPhotoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _removePhoto() {
    setState(() {
      _localFile = null;
      _imageBytes = null;
      _uploadedPhotoUrl = null;
    });
    widget.onPhotoUploaded(null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Photo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourceDialog,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: _isUploading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _imageBytes != null
                    ? ClipOval(
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to network image if memory fails
                            return Image.network(
                              widget.currentPhotoUrl ?? '',
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            );
                          },
                        ),
                      )
                    : widget.currentPhotoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              widget.currentPhotoUrl!,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            ),
                          )
                        : _buildPlaceholder(),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _isUploading ? null : _showImageSourceDialog,
          icon: const Icon(Icons.add_a_photo),
          label: Text(_isUploading ? 'Uploading...' : 'Add/Change Photo'),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_add_outlined,
          size: 50,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add\nphoto',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

