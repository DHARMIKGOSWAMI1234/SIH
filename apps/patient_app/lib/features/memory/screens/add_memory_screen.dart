import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../core/widgets/smriti_primary_button.dart';
import '../../../core/widgets/smriti_card.dart';
import '../../../data/local/repositories/smriti_repository.dart';
import '../../../l10n/app_strings.dart';
import '../models/memory_categories.dart';
import '../services/memory_media_service.dart';

/// Elderly-friendly and caregiver-friendly memory creation flow.
///
/// Features real Android/iOS Gallery image picking, preview, metadata collection,
/// and local Drift SQLite persistence.
class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _personNameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  MemoryCategory _selectedCategory = MemoryCategory.family;
  DateTime? _selectedDate;
  String? _selectedImagePath;
  String? _selectedAudioPath;
  bool _isPickingImage = false;
  bool _isRecording = false;
  bool _hasAudioNote = false;
  bool _isSaving = false;

  static const List<String> _quickRelationships = [
    'Grandson',
    'Granddaughter',
    'Daughter',
    'Son',
    'Spouse',
    'Friend',
    'Neighbor',
    'Sister',
    'Brother',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _personNameController.dispose();
    _relationshipController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image != null && image.path.isNotEmpty) {
        // Copy to persistent local media directory
        final localPath = await MemoryMediaService.copyPhotoToLocalStorage(image.path);
        if (mounted) {
          setState(() {
            _selectedImagePath = localPath ?? image.path;
          });
        }
      }
    } catch (e) {
      debugPrint('[AddMemoryScreen] Error selecting photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open gallery: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Select Memory Date (Optional)',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _toggleMockVoiceNote() {
    setState(() {
      if (_isRecording) {
        _isRecording = false;
        _hasAudioNote = true;
        _selectedAudioPath = 'local_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      } else if (_hasAudioNote) {
        _hasAudioNote = false;
        _selectedAudioPath = null;
      } else {
        _isRecording = true;
      }
    });
  }

  Future<void> _saveMemory() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a memory title'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final repo = context.read<SmritiRepository>();

    try {
      final desc = _descriptionController.text.trim();
      await repo.insertMemory(
        title: title,
        description: desc.isNotEmpty ? desc : title,
        category: _selectedCategory.id,
        personName: _personNameController.text.trim().isEmpty ? null : _personNameController.text.trim(),
        relationship: _relationshipController.text.trim().isEmpty ? null : _relationshipController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        eventDate: _selectedDate,
        imagePath: _selectedImagePath,
        audioPath: _selectedAudioPath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Memory saved safely to your Personal Memory Bank.'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving memory: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final inputFill = isDark ? AppColors.darkBackground : const Color(0xFFF7F3EA);

    return SmritiScaffold(
      title: 'Add New Memory',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          children: [
            Text(
              'Capture a Cherished Moment',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Add a personal photo or story to keep familiar memories close.',
              style: TextStyle(
                fontSize: 16.0,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 20.0),

            // 1. PHOTO MEMORY / GALLERY PICKER
            _buildLabel('Memory Photo', isDark, textPrimary),
            if (_selectedImagePath != null && File(_selectedImagePath!).existsSync())
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.0),
                  child: Stack(
                    children: [
                      Image.file(
                        File(_selectedImagePath!),
                        height: 220.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180.0,
                          color: cardColor,
                          child: Center(
                            child: Icon(Icons.broken_image_rounded, size: 48, color: textSecondary),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() => _selectedImagePath = null),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.close, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cardColor.withValues(alpha: 0.9),
                            foregroundColor: textPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.photo_library_rounded, size: 18),
                          label: const Text('Change Photo'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SmritiCard(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSoftBlue : const Color(0xFFEDE9DE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 40.0,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Choose a photo from your device',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Family gathering, familiar home, portrait, or pet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
                        minimumSize: const Size(200, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isPickingImage ? null : _pickImageFromGallery,
                      icon: _isPickingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.photo_library_rounded, size: 22),
                      label: Text(
                        _isPickingImage ? 'Opening Gallery...' : 'Choose from Gallery',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20.0),

            // 2. Title
            _buildLabel('Memory Title *', isDark, textPrimary),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('e.g., Afternoon Tea on the Veranda', isDark, inputFill, borderColor, primaryColor, textSecondary),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: textPrimary),
            ),
            const SizedBox(height: 18.0),

            // 3. Category Selection Chips
            _buildLabel('Category', isDark, textPrimary),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: MemoryCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    AppStrings.get(cat.localizationKey),
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? (isDark ? AppColors.darkBackground : Colors.white) : textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: cardColor,
                  side: BorderSide(color: isSelected ? primaryColor : borderColor),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18.0),

            // 4. Who is this? (Person Name)
            _buildLabel('Who is this? (Optional)', isDark, textPrimary),
            TextFormField(
              controller: _personNameController,
              decoration: _inputDecoration('e.g., Grandson Rahul', isDark, inputFill, borderColor, primaryColor, textSecondary),
              style: TextStyle(fontSize: 18.0, color: textPrimary),
            ),
            const SizedBox(height: 18.0),

            // 5. Relationship
            _buildLabel('Relationship (Optional)', isDark, textPrimary),
            TextFormField(
              controller: _relationshipController,
              decoration: _inputDecoration('e.g., Grandson', isDark, inputFill, borderColor, primaryColor, textSecondary),
              style: TextStyle(fontSize: 18.0, color: textPrimary),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: _quickRelationships.map((rel) {
                return ActionChip(
                  label: Text(rel, style: TextStyle(fontSize: 13.0, color: textPrimary)),
                  backgroundColor: cardColor,
                  side: BorderSide(color: borderColor),
                  onPressed: () {
                    setState(() => _relationshipController.text = rel);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18.0),

            // 6. Location
            _buildLabel('Place / Location (Optional)', isDark, textPrimary),
            TextFormField(
              controller: _locationController,
              decoration: _inputDecoration('e.g., Majuli Island, Assam', isDark, inputFill, borderColor, primaryColor, textSecondary),
              style: TextStyle(fontSize: 18.0, color: textPrimary),
            ),
            const SizedBox(height: 18.0),

            // 7. Date Picker Button
            _buildLabel('When did this happen? (Optional)', isDark, textPrimary),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: Icon(Icons.calendar_today_rounded, size: 20.0, color: primaryColor),
              label: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Select Year or Date',
                style: TextStyle(fontSize: 16.0, color: textPrimary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor, width: 1.5),
                backgroundColor: cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                minimumSize: const Size(double.infinity, 52.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 18.0),

            // 8. Voice Note Recorder
            _buildLabel('Voice Note (Optional)', isDark, textPrimary),
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _toggleMockVoiceNote,
                    icon: Icon(
                      _isRecording
                          ? Icons.stop_circle_rounded
                          : (_hasAudioNote ? Icons.delete_outline_rounded : Icons.mic_rounded),
                      color: _isRecording
                          ? AppColors.errorRed
                          : (_hasAudioNote ? AppColors.errorRed : primaryColor),
                      size: 32.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _isRecording
                          ? 'Recording... Tap to stop'
                          : (_hasAudioNote ? 'Voice note attached (Tap icon to remove)' : 'Tap mic to record audio note'),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18.0),

            // 9. Description / Story
            _buildLabel('Description / Story (Optional)', isDark, textPrimary),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration('Share a warm note or story about this memory...', isDark, inputFill, borderColor, primaryColor, textSecondary),
              style: TextStyle(fontSize: 17.0, color: textPrimary),
            ),
            const SizedBox(height: 28.0),

            // 10. Save Button
            SmritiPrimaryButton(
              label: _isSaving ? 'Saving Memory...' : 'Save Memory',
              icon: Icons.check_circle_rounded,
              onPressed: _isSaving ? null : _saveMemory,
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    bool isDark,
    Color fillColor,
    Color borderColor,
    Color primaryColor,
    Color hintColor,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 15.0,
        color: hintColor.withAlpha(150),
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
    );
  }
}
