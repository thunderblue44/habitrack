// filepath: /home/karsterr/Projects/habitrack/lib/widgets/habit_tracking_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/habit_track.dart';
import '../providers/habit_provider.dart';
import 'loading_indicator.dart';

class HabitTrackingDialog extends StatefulWidget {
  final Habit habit;
  final Function(bool success)? onTrackAdded;

  const HabitTrackingDialog({
    super.key,
    required this.habit,
    this.onTrackAdded,
  });

  static Future<void> show(
    BuildContext context,
    Habit habit, {
    Function(bool)? onTrackAdded,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              HabitTrackingDialog(habit: habit, onTrackAdded: onTrackAdded),
    );
  }

  @override
  State<HabitTrackingDialog> createState() => _HabitTrackingDialogState();
}

class _HabitTrackingDialogState extends State<HabitTrackingDialog> {
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  bool _isSubmitting = false;
  bool _showSuccess = false;
  String? _errorMessage;

  // Helper method to convert habit.color to a Flutter Color
  Color _getHabitColor() {
    if (widget.habit.color == null) {
      return Theme.of(context).colorScheme.primary;
    }

    // If habit.color is an int, convert it to a Color
    if (widget.habit.color is int) {
      return Color(widget.habit.color as int);
    }

    // If habit.color is a String, parse it to a Color
    if (widget.habit.color is String) {
      try {
        // Try to parse a hex color string (like "#FFAABB")
        final colorString = widget.habit.color as String;
        if (colorString.startsWith('#')) {
          return Color(int.parse('FF${colorString.substring(1)}', radix: 16));
        }
      } catch (e) {
        // Fall back to primary color if parsing fails
      }
    }

    // Default fallback
    return Theme.of(context).colorScheme.primary;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDateTimePicker(),
                const SizedBox(height: 16),
                _buildNotesField(),
                const SizedBox(height: 24),
                _buildTrackingButtons(),
                if (_errorMessage != null) _buildErrorMessage(),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildHeader() {
    final habitColor = _getHabitColor();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: habitColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.habit.icon != null
                ? IconData(
                  // Convert string to int if needed
                  widget.habit.icon is String
                      ? int.parse(widget.habit.icon as String)
                      : widget.habit.icon as int,
                  fontFamily: 'MaterialIcons',
                )
                : Icons.check_circle_outline,
            color: habitColor,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Track "${widget.habit.name}"',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.habit.description ?? 'Mark this habit as completed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When did you complete this habit?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Date picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  _formatDate(_selectedDateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _selectDate(context),
              ),

              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),

              // Time picker
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(
                  _formatTime(_selectedDateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _selectTime(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Add any details about this completion...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTrackingButtons() {
    final habitColor = _getHabitColor();

    if (_showSuccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 16),
            Text(
              'Habit tracked successfully!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.green),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }

    return _isSubmitting
        ? const Center(child: LoadingIndicator(message: 'Tracking habit...'))
        : Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _trackHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: habitColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Track Now'),
              ),
            ),
          ],
        );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ).animate().shake();
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    // Using DateTime.now() as default start date if not available
    final DateTime habitStartDate = widget.habit.createdAt ?? DateTime(2020);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: habitStartDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _trackHabit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      // Check if date is in the future
      if (_selectedDateTime.isAfter(DateTime.now())) {
        throw Exception('Cannot track habits in the future');
      }

      // Create tracking entry
      final track = HabitTrackRecord(
        habitId: widget.habit.id!,
        date: _selectedDateTime,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
      );

      // Save to backend
      final result = await habitProvider.trackHabit(track);

      // Handle success
      if (result) {
        widget.onTrackAdded?.call(result);
        setState(() {
          _isSubmitting = false;
          _showSuccess = true;
        });

        // Close dialog after showing success for a moment
        if (!mounted) return;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        throw Exception('Failed to track habit');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });
    }
  }
}
