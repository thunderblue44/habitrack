import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../utils/habit_utils.dart';
import '../widgets/input_field.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({Key? key}) : super(key: key);

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController(text: '1');

  // Form values
  HabitType _habitType = HabitType.positive;
  FrequencyUnit _frequencyUnit = FrequencyUnit.daily;

  // Reminder settings
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = TimeOfDay.now();
  final List<bool> _reminderDays = List.generate(7, (_) => true);

  // Appearance
  String _selectedColor = HabitColors.getColorCodes().first;
  String _selectedIcon = 'check';

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _createHabit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      if (authProvider.user == null) {
        throw Exception('You must be logged in to create a habit');
      }

      // Convert reminder days to string format
      String? reminderDaysString;
      if (_reminderEnabled) {
        final List<int> selectedDays = [];
        for (int i = 0; i < _reminderDays.length; i++) {
          if (_reminderDays[i]) {
            // Use 1-based indexing (1 = Monday, 7 = Sunday)
            selectedDays.add(i + 1);
          }
        }
        reminderDaysString = selectedDays.join(',');
      }

      // Create the habit
      final habit = Habit(
        userId: authProvider.user!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _habitType,
        goal: int.tryParse(_goalController.text) ?? 1,
        frequencyUnit: _frequencyUnit,
        reminderEnabled: _reminderEnabled,
        reminderTime: _reminderEnabled ? _formatTimeOfDay(_reminderTime) : null,
        reminderDays: reminderDaysString,
        color: _selectedColor,
        icon: _selectedIcon,
      );

      final success = await habitProvider.createHabit(habit);

      if (success && mounted) {
        Navigator.pop(context);
      } else {
        setState(() {
          _error = 'Failed to create habit. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (pickedTime != null) {
      setState(() {
        _reminderTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!.replaceAll('Exception: ', ''),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Habit type selection
              _buildSectionTitle('Habit Type'),
              SegmentedButton<HabitType>(
                segments: const [
                  ButtonSegment(
                    value: HabitType.positive,
                    icon: Icon(Icons.add_circle_outline),
                    label: Text('Build'),
                  ),
                  ButtonSegment(
                    value: HabitType.negative,
                    icon: Icon(Icons.remove_circle_outline),
                    label: Text('Break'),
                  ),
                ],
                selected: {_habitType},
                onSelectionChanged: (Set<HabitType> selection) {
                  setState(() {
                    _habitType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Basic info
              _buildSectionTitle('Basic Information'),
              InputField(
                controller: _nameController,
                label: 'Habit Name',
                hint: 'e.g., Drink Water, Exercise, Read',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  if (value.length > 50) {
                    return 'Name must be 50 characters or less';
                  }
                  return null;
                },
              ),

              InputField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add more details about your habit',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Goal settings
              _buildSectionTitle('Goal Settings'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: InputField(
                      controller: _goalController,
                      label: 'Target',
                      hint: 'e.g., 1, 2, 3',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a target';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 1) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Frequency',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        DropdownButtonFormField<FrequencyUnit>(
                          value: _frequencyUnit,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items:
                              FrequencyUnit.values.map((unit) {
                                return DropdownMenuItem<FrequencyUnit>(
                                  value: unit,
                                  child: Text(unit.toString().split('.').last),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _frequencyUnit = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reminder settings
              _buildSectionTitle('Reminder Settings'),
              SwitchListTile(
                title: const Text('Enable Reminders'),
                subtitle: Text(
                  _reminderEnabled
                      ? 'You will receive reminders at ${_reminderTime.format(context)}'
                      : 'No reminders will be sent',
                ),
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _reminderEnabled = value;
                  });
                },
              ),

              if (_reminderEnabled) ...[
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(_reminderTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _selectTime,
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, bottom: 4),
                  child: Text('Days of the Week'),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _buildDayChip(0, 'M'),
                      _buildDayChip(1, 'T'),
                      _buildDayChip(2, 'W'),
                      _buildDayChip(3, 'T'),
                      _buildDayChip(4, 'F'),
                      _buildDayChip(5, 'S'),
                      _buildDayChip(6, 'S'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Appearance settings
              _buildSectionTitle('Appearance'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Icon',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              HabitIcons.icons.entries.map((entry) {
                                final isSelected = _selectedIcon == entry.key;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedIcon = entry.key;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? HabitColors.getColor(
                                                  _selectedColor,
                                                ).withOpacity(0.2)
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                        border:
                                            isSelected
                                                ? Border.all(
                                                  color: HabitColors.getColor(
                                                    _selectedColor,
                                                  ),
                                                  width: 2,
                                                )
                                                : null,
                                      ),
                                      child: Icon(
                                        entry.value,
                                        color:
                                            isSelected
                                                ? HabitColors.getColor(
                                                  _selectedColor,
                                                )
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Color',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              HabitColors.getColorCodes().map((colorCode) {
                                final color = HabitColors.getColor(colorCode);
                                final isSelected = _selectedColor == colorCode;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = colorCode;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            isSelected
                                                ? Border.all(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                  width: 2,
                                                )
                                                : null,
                                      ),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                            isSelected
                                                ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 18,
                                                )
                                                : null,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Create Habit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDayChip(int index, String label) {
    return FilterChip(
      label: Text(label),
      selected: _reminderDays[index],
      onSelected: (selected) {
        setState(() {
          _reminderDays[index] = selected;
        });
      },
    );
  }
}
