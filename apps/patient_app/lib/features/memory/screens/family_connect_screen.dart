import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../core/widgets/smriti_primary_button.dart';
import '../../../core/widgets/smriti_card.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/local/repositories/smriti_repository.dart';
import '../../help/models/help_screen_id.dart';
import '../models/memory_categories.dart';
import 'memory_detail_screen.dart';

/// Family Connect Screen: Local Demo Foundation for family memory contributions.
///
/// State: DEMO FOUNDATION
/// Allows family members to contribute memories locally with clear indication
/// that external cloud synchronization is scheduled for a future phase.
class FamilyConnectScreen extends StatefulWidget {
  const FamilyConnectScreen({super.key});

  @override
  State<FamilyConnectScreen> createState() => _FamilyConnectScreenState();
}

class _FamilyConnectScreenState extends State<FamilyConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  String _selectedCategory = MemoryCategory.family.id;
  bool _isRecordingDemo = false;
  bool _hasVoiceDemo = false;
  bool _isSaving = false;
  bool _showAddForm = false;
  List<Memory> _familyMemories = [];
  bool _isLoading = true;

  final List<String> _commonRelationships = [
    'Daughter',
    'Son',
    'Grandchild',
    'Spouse',
    'Brother',
    'Sister',
    'Caregiver',
    'Friend',
  ];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    final repo = context.read<SmritiRepository>();
    final all = await repo.getMemories(includeArchived: false);
    final filtered = all.where((m) => m.source == 'family_connect').toList();
    if (mounted) {
      setState(() {
        _familyMemories = filtered;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFamilyContribution() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final repo = context.read<SmritiRepository>();
      final yearText = _yearController.text.trim();
      DateTime? eventDate;
      if (yearText.isNotEmpty) {
        final year = int.tryParse(yearText);
        if (year != null && year > 1900 && year < 2100) {
          eventDate = DateTime(year, 1, 1);
        }
      }

      await repo.insertMemory(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        personName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        relationship: _relationshipController.text.trim().isEmpty ? null : _relationshipController.text.trim(),
        eventDate: eventDate,
        source: 'family_connect',
        tags: 'family_connect,demo_foundation',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory saved to Personal Memory Bank!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _titleController.clear();
        _descriptionController.clear();
        _yearController.clear();
        setState(() {
          _showAddForm = false;
          _hasVoiceDemo = false;
        });
        _loadMemories();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _seedDemoFamilyMemory() async {
    final repo = context.read<SmritiRepository>();
    await repo.insertMemory(
      title: 'Family Gathering for Rongali Bihu',
      description: 'Ananya made fresh Til Pitha and we all sat in the courtyard singing Bihu songs.',
      category: 'festivals',
      personName: 'Ananya',
      relationship: 'Daughter',
      eventDate: DateTime(2023, 4, 14),
      source: 'family_connect',
      tags: 'family_connect,demo_foundation',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample family contribution added!'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadMemories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: 'Family Connect',
      helpScreenId: HelpScreenId.familyConnect,
      actions: [
        IconButton(
          icon: Icon(_showAddForm ? Icons.close_rounded : Icons.add_circle_outline_rounded, size: 28.0),
          tooltip: _showAddForm ? 'Close Form' : 'Contribute Memory',
          onPressed: () => setState(() => _showAddForm = !_showAddForm),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Demo Foundation Banner
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.warmCream.withValues(alpha: isDark ? 0.08 : 0.6),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.people_alt_rounded, color: AppColors.accentGold, size: 30.0),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Family Contribution Foundation',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Family members can contribute stories, photos, and voice notes locally. Contributions are saved into the Personal Memory Bank.',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Contribution Form or Toggle
            if (_showAddForm) ...[
              _buildContributionForm(isDark),
              const SizedBox(height: 24.0),
            ] else ...[
              SmritiPrimaryButton(
                label: '+ Add Family Memory',
                icon: Icons.favorite_rounded,
                onPressed: () => setState(() => _showAddForm = true),
              ),
              const SizedBox(height: 24.0),
            ],

            // Existing Family Contributions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Family Contributions',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.playlist_add_rounded, size: 20.0),
                  label: const Text('Add Demo'),
                  onPressed: _seedDemoFamilyMemory,
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // List of family memories
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else if (_familyMemories.isEmpty)
              _buildEmptyState(isDark)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _familyMemories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                itemBuilder: (context, index) {
                  final item = _familyMemories[index];
                  return _buildMemoryCard(item, isDark);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionForm(bool isDark) {
    return Form(
      key: _formKey,
      child: SmritiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen, size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  'Contribute a Memory',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Memory Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Memory / Milestone Title *',
                hintText: 'e.g. Visiting Majuli Island together',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 14.0),

            // Person Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name (Family Contributor)',
                hintText: 'e.g. Priya Sharma',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 14.0),

            // Relationship Dropdown / Field
            DropdownButtonFormField<String>(
              initialValue: _relationshipController.text.isEmpty ? null : _relationshipController.text,
              decoration: const InputDecoration(
                labelText: 'Relationship to Patient',
                prefixIcon: Icon(Icons.family_restroom_rounded),
              ),
              hint: const Text('Select relationship'),
              items: _commonRelationships.map((r) {
                return DropdownMenuItem(value: r, child: Text(r));
              }).toList(),
              onChanged: (val) {
                if (val != null) _relationshipController.text = val;
              },
            ),
            const SizedBox(height: 14.0),

            // Year / Date
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Approximate Year (Optional)',
                hintText: 'e.g. 2018',
                prefixIcon: Icon(Icons.calendar_today_rounded),
              ),
            ),
            const SizedBox(height: 14.0),

            // Category Selector
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: MemoryCategory.values.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 18.0),
                      const SizedBox(width: 8.0),
                      Text(c.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 14.0),

            // Description / Story
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Story or Loving Message *',
                hintText: 'Write the memory or message in clear, warm words...',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please share a few words' : null,
            ),
            const SizedBox(height: 16.0),

            // Voice Note Foundation (Demo control)
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isRecordingDemo ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isRecordingDemo ? AppColors.error : AppColors.primaryGreen,
                    size: 26.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isRecordingDemo
                              ? 'Recording local demo note...'
                              : (_hasVoiceDemo ? 'Demo voice note attached' : 'Add Voice Note (Demo)'),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.0),
                        ),
                        Text(
                          _hasVoiceDemo
                              ? '00:15 recorded note ready to attach'
                              : 'Tap button to simulate voice attachment',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecordingDemo ? AppColors.error : AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      if (_isRecordingDemo) {
                        setState(() {
                          _isRecordingDemo = false;
                          _hasVoiceDemo = true;
                        });
                      } else {
                        setState(() => _isRecordingDemo = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted && _isRecordingDemo) {
                            setState(() {
                              _isRecordingDemo = false;
                              _hasVoiceDemo = true;
                            });
                          }
                        });
                      }
                    },
                    child: Text(_isRecordingDemo ? 'Stop' : (_hasVoiceDemo ? 'Replace' : 'Record')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Save Action
            SmritiPrimaryButton(
              label: _isSaving ? 'Saving...' : 'Save to Memory Bank',
              icon: Icons.check_circle_rounded,
              onPressed: _isSaving ? null : _saveFamilyContribution,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.family_restroom_rounded,
            size: 54.0,
            color: AppColors.primaryGreen.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12.0),
          Text(
            'No family contributions yet',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Loved ones can contribute photos and stories here. Tap "Add Demo" above or the button below to add your first contribution.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(Memory item, bool isDark) {
    final contributor = item.personName ?? 'Family Member';
    final relationship = item.relationship != null ? ' (${item.relationship})' : '';

    return SmritiCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MemoryDetailScreen(memory: item)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.primaryGreen,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: const Text(
                        'Family',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Added by $contributor$relationship',
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }
}
