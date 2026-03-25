import 'package:flutter/material.dart';
import 'gender_selector_widget.dart';
import 'date_picker_widget.dart';
import 'photo_upload_widget.dart';

/// Complete reusable person form widget
class PersonFormWidget extends StatefulWidget {
  final String? initialName;
  final String? initialGender;
  final DateTime? initialDob;
  final DateTime? initialDod;
  final String? initialPhotoUrl;
  final bool isLoading;
  final Function(String name, String? gender, DateTime? dob, DateTime? dod, String? photoUrl)
      onSave;
  final VoidCallback? onCancel;

  const PersonFormWidget({
    super.key,
    this.initialName,
    this.initialGender,
    this.initialDob,
    this.initialDod,
    this.initialPhotoUrl,
    this.isLoading = false,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<PersonFormWidget> createState() => _PersonFormWidgetState();
}

class _PersonFormWidgetState extends State<PersonFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedGender;
  DateTime? _selectedDob;
  DateTime? _selectedDod;
  String? _photoUrl;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedGender = widget.initialGender;
    _selectedDob = widget.initialDob;
    _selectedDod = widget.initialDod;
    _photoUrl = widget.initialPhotoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isDirty {
    return _nameController.text != (widget.initialName ?? '') ||
        _selectedGender != widget.initialGender ||
        _selectedDob != widget.initialDob ||
        _selectedDod != widget.initialDod ||
        _photoUrl != widget.initialPhotoUrl;
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        _selectedGender,
        _selectedDob,
        _selectedDod,
        _photoUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo Upload
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PhotoUploadWidget(
              currentPhotoUrl: _photoUrl,
              onPhotoUploaded: (url) {
                setState(() {
                  _photoUrl = url;
                });
              },
              isLoading: widget.isLoading,
            ),
          ),
          const SizedBox(height: 24),

          // Name Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter full name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _nameError,
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
              onChanged: (value) {
                if (_nameError != null) {
                  setState(() {
                    _nameError = null;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),

          // Gender Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GenderSelector(
              value: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              errorText: null,
            ),
          ),
          const SizedBox(height: 20),

          // Date of Birth Picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DatePickerWidget(
              label: 'Date of Birth',
              value: _selectedDob,
              onChanged: (value) {
                setState(() {
                  _selectedDob = value;
                });
              },
              errorText: null,
            ),
          ),
          const SizedBox(height: 20),

          // Date of Death Picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DatePickerWidget(
              label: 'Date of Death (Optional)',
              value: _selectedDod,
              onChanged: (value) {
                setState(() {
                  _selectedDod = value;
                });
              },
              errorText: null,
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                if (widget.onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.isLoading ? null : widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                if (widget.onCancel != null) const SizedBox(width: 12),
                Expanded(
                  flex: widget.onCancel != null ? 2 : 1,
                  child: FilledButton.icon(
                    onPressed: widget.isLoading ? null : _handleSave,
                    icon: widget.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(widget.isLoading ? 'Saving...' : 'Save'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
