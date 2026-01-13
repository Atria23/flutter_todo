// --- START OF FILE lib/screens/edit_task_page.dart (MODIFIED - NEW LAYOUT) ---

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:doable_todo_list_app/services/notification_service.dart';
import 'package:doable_todo_list_app/models/todo.dart';
import 'package:doable_todo_list_app/providers/todo_provider.dart';
import 'package:doable_todo_list_app/theme/app_theme.dart'; // Import tema
import 'package:doable_todo_list_app/widgets/common_form_widgets.dart'; // Import widget umum

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late Todo _originalTodo;

  bool _reminder = false;
  String? _repeatRule;
  final Set<int> _repeatWeekdays = {};
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  EdgeInsets get _screenHPad {
    final w = MediaQuery.of(context).size.width;
    final hpad = (w * 0.05).clamp(20.0, 24.0);
    return EdgeInsets.symmetric(horizontal: hpad);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      _originalTodo = arg as Todo;

      _titleCtrl.text = _originalTodo.title;
      _descCtrl.text = _originalTodo.description ?? '';

      _reminder = _originalTodo.hasNotification;
      _repeatRule = _originalTodo.repeatRule;
      _hydrateWeekdaysFromRule(_repeatRule);

      _selectedDate = _originalTodo.scheduledDate;
      _selectedTime = _originalTodo.scheduledTime != null
          ? TimeOfDay.fromDateTime(_originalTodo.scheduledTime!)
          : null;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => DateFormat('dd/MM/yy').format(d);
  String _formatTime(TimeOfDay t) {
    final dt = DateTime(0, 1, 1, t.hour, t.minute);
    return DateFormat('h:mm a').format(dt);
  }

  void _hydrateWeekdaysFromRule(String? rule) {
    _repeatWeekdays.clear();
    if (rule == null) return;
    if (!rule.startsWith('Weekly')) return;

    final exp = RegExp(r'(\d+)');
    for (final m in exp.allMatches(rule)) {
      final v = int.tryParse(m.group(1)!);
      if (v != null && v >= 1 && v <= 7) _repeatWeekdays.add(v);
    }
  }

  void _selectRepeatRule(String rule) {
    setState(() {
      _repeatRule = rule;
      if (rule != 'Weekly') {
        _repeatWeekdays.clear();
      }
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select date',
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Select time',
    );
    if (picked != null) setState(() => _selectedTime = picked);
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

  Future<void> _save() async {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    String? normalizedRepeat;
    if (_repeatRule == null || _repeatRule == 'No repeat') {
      normalizedRepeat = null;
    } else if (_repeatRule == 'Weekly' && _repeatWeekdays.isNotEmpty) {
      final list = _repeatWeekdays.toList()..sort();
      normalizedRepeat = 'Weekly:${list.toString()}';
    } else {
      normalizedRepeat = _repeatRule;
    }

    final updatedTodo = _originalTodo.copyWith(
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      scheduledTime: _selectedTime != null ? DateTime(0, 1, 1, _selectedTime!.hour, _selectedTime!.minute) : null,
      scheduledDate: _selectedDate,
      hasNotification: _reminder,
      repeatRule: normalizedRepeat,
      completed: _originalTodo.completed,
      lastUpdate: DateTime.now(),
    );

    await todoProvider.updateTodo(updatedTodo);
    final allTodos = todoProvider.todos;
    await NotificationService.rescheduleAllNotifications(allTodos);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!(_titleCtrl.text.isNotEmpty || ModalRoute.of(context)?.settings.arguments != null)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryBlue)));
    }

    final spacing = 16.0;
    final bigSpacing = 24.0;

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
          'Modify To-Do',
          style: headline1Style,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _screenHPad.add(const EdgeInsets.only(bottom: 24, top: 8)),
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
                  const SizedBox(height: 12),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: SafeArea(
          top: false,
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
              child: const Text('Save Changes'),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Widget untuk mengelompokkan section-section (sama seperti di add_task_page.dart)
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: subtitle1Style.copyWith(color: darkGrey, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
// --- END OF FILE lib/screens/edit_task_page.dart (MODIFIED - NEW LAYOUT) ---