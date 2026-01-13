// --- START OF FILE lib/screens/add_task_page.dart (MODIFIED - NEW LAYOUT) ---

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:doable_todo_list_app/services/notification_service.dart';
import 'package:doable_todo_list_app/models/todo.dart';
import 'package:doable_todo_list_app/providers/todo_provider.dart';
import 'package:doable_todo_list_app/theme/app_theme.dart'; // Import tema
import 'package:doable_todo_list_app/widgets/common_form_widgets.dart'; // Import widget umum

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _reminder = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _repeatRule;
  final Set<int> _repeatWeekdays = {};

  EdgeInsets get _screenHPad {
    final w = MediaQuery.of(context).size.width;
    final hpad = (w * 0.05).clamp(20.0, 24.0);
    return EdgeInsets.symmetric(horizontal: hpad);
  }

  String _formatDate(DateTime d) => DateFormat('dd/MM/yy').format(d);
  String _formatTime(TimeOfDay t) {
    final dt = DateTime(0, 1, 1, t.hour, t.minute);
    return DateFormat('h:mm a').format(dt);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select date',
      builder: (ctx, child) {
        return child!;
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Select time',
      builder: (ctx, child) => child!,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleReminder() async {
    final userEnabled = await NotificationService.areNotificationsEnabledByUser();

    if (!userEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notifications are disabled in settings'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, 'settings');
            },
          ),
        ),
      );
      return;
    }

    setState(() => _reminder = !_reminder);
  }

  void _selectRepeatRule(String rule) {
    setState(() {
      _repeatRule = rule;
      if (rule != 'Weekly') _repeatWeekdays.clear();
    });
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_repeatWeekdays.contains(weekday)) {
        _repeatWeekdays.remove(weekday);
      } else {
        _repeatWeekdays.add(weekday);
      }
      if (_repeatWeekdays.isNotEmpty) {
        _repeatRule = 'Weekly';
      } else if (_repeatRule == 'Weekly') {
        _repeatRule = 'No repeat';
      }
    });
  }

  Future<void> _save() async {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    String? repeatRule;
    if (_repeatRule == null || _repeatRule == 'No repeat') {
      repeatRule = null;
    } else if (_repeatRule == 'Weekly' && _repeatWeekdays.isNotEmpty) {
      repeatRule = 'Weekly:${_repeatWeekdays.toList()..sort()}';
    } else {
      repeatRule = _repeatRule;
    }

    final newTodo = Todo(
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      scheduledTime: _selectedTime != null ? DateTime(0, 1, 1, _selectedTime!.hour, _selectedTime!.minute) : null,
      scheduledDate: _selectedDate,
      hasNotification: _reminder,
      repeatRule: repeatRule,
      completed: false,
      creationTime: DateTime.now(),
      lastUpdate: DateTime.now(),
    );

    await todoProvider.addTodo(newTodo);
    final allTodos = todoProvider.todos;
    await NotificationService.rescheduleAllNotifications(allTodos);


    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 16.0;
    final bigSpacing = 24.0;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(Icons.arrow_back, color: darkGrey),
          tooltip: 'Back',
        ),
        title: const Text(
          'Create To-Do',
          style: headline1Style,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24).add(_screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section: Set Reminder ---
              _SectionCard(
                title: 'Reminder Settings',
                children: [
                  ReminderButton(
                    enabled: _reminder,
                    onTap: _toggleReminder,
                  ),
                ],
              ),
              SizedBox(height: bigSpacing),

              // --- Section: Task Details ---
              _SectionCard(
                title: 'Task Details',
                children: [
                  InputField(
                    controller: _titleCtrl,
                    hint: 'Title',
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: spacing),
                  InputField(
                    controller: _descCtrl,
                    hint: 'Description',
                    maxLines: 3,
                  ),
                ],
              ),
              SizedBox(height: bigSpacing),

              // --- Section: Repeat Schedule ---
              _SectionCard(
                title: 'Repeat Schedule',
                children: [
                  // Frequency chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      RepeatChip(
                        label: 'Daily',
                        selected: _repeatRule == 'Daily',
                        onTap: () => _selectRepeatRule('Daily'),
                      ),
                      RepeatChip(
                        label: 'Weekly',
                        selected: _repeatRule == 'Weekly',
                        onTap: () => _selectRepeatRule('Weekly'),
                      ),
                      RepeatChip(
                        label: 'Monthly',
                        selected: _repeatRule == 'Monthly',
                        onTap: () => _selectRepeatRule('Monthly'),
                      ),
                      RepeatChip(
                        label: 'No repeat',
                        selected: _repeatRule == null || _repeatRule == 'No repeat' || (_repeatRule == 'Weekly' && _repeatWeekdays.isEmpty),
                        onTap: () => _selectRepeatRule('No repeat'),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  // Weekday chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      WeekdayChip(
                        label: 'Monday',
                        selected: _repeatWeekdays.contains(1),
                        onTap: () => _toggleWeekday(1),
                      ),
                      WeekdayChip(
                        label: 'Tuesday',
                        selected: _repeatWeekdays.contains(2),
                        onTap: () => _toggleWeekday(2),
                      ),
                      WeekdayChip(
                        label: 'Wednesday',
                        selected: _repeatWeekdays.contains(3),
                        onTap: () => _toggleWeekday(3),
                      ),
                      WeekdayChip(
                        label: 'Thursday',
                        selected: _repeatWeekdays.contains(4),
                        onTap: () => _toggleWeekday(4),
                      ),
                      WeekdayChip(
                        label: 'Friday',
                        selected: _repeatWeekdays.contains(5),
                        onTap: () => _toggleWeekday(5),
                      ),
                      WeekdayChip(
                        label: 'Saturday',
                        selected: _repeatWeekdays.contains(6),
                        onTap: () => _toggleWeekday(6),
                      ),
                      WeekdayChip(
                        label: 'Sunday',
                        selected: _repeatWeekdays.contains(7),
                        onTap: () => _toggleWeekday(7),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: bigSpacing),

              // --- Section: Date & Time ---
              _SectionCard(
                title: 'Scheduled Date & Time',
                children: [
                  PickerField(
                    hint: 'Set date',
                    valueText: _selectedDate != null ? _formatDate(_selectedDate!) : null,
                    iconAsset: 'assets/calendar.svg',
                    onTap: _pickDate,
                    onClear: _selectedDate != null
                        ? () => setState(() => _selectedDate = null)
                        : null,
                  ),
                  SizedBox(height: spacing),
                  PickerField(
                    hint: 'Set time',
                    valueText: _selectedTime != null ? _formatTime(_selectedTime!) : null,
                    iconAsset: 'assets/clock.svg',
                    onTap: _pickTime,
                    onClear: _selectedTime != null
                        ? () => setState(() => _selectedTime = null)
                        : null,
                  ),
                ],
              ),
              SizedBox(height: width * 0.1),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: chipTextStyle.copyWith(fontSize: 16, color: Colors.white),
              ),
              onPressed: _save,
              child: const Text('Save To-Do'),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Widget untuk mengelompokkan section-section
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      padding: const EdgeInsets.all(20), // Padding internal
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: subtitle1Style.copyWith(color: darkGrey, fontSize: 18),
          ),
          const SizedBox(height: 16), // Spasi antara judul dan konten
          ...children, // Isi konten dari children
        ],
      ),
    );
  }
}
// --- END OF FILE lib/screens/add_task_page.dart (MODIFIED - NEW LAYOUT) ---