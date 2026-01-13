// --- START OF FILE lib/screens/home_page.dart (MODIFIED - NEW LAYOUT) ---
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:doable_todo_list_app/models/todo.dart';
import 'package:doable_todo_list_app/providers/todo_provider.dart';
import 'package:doable_todo_list_app/theme/app_theme.dart'; // Import tema
import 'package:doable_todo_list_app/widgets/common_form_widgets.dart'; // Import widget umum

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ---- Filter state ----
  DateTime? _fltDate;
  DateTime? _fltTime;
  bool? _fltCompleted;
  String? _fltRepeat;
  bool? _fltReminder;

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yy').format(d);
  String _fmtTime(DateTime dt) => DateFormat('h:mm a').format(dt);

  List<Todo> _getFilteredTodos(List<Todo> allTodos) {
    Iterable<Todo> it = allTodos;

    if (_fltDate != null) {
      final filterDateFormatted = _fmtDate(_fltDate!);
      it = it.where((t) => (t.scheduledDate != null &&
          _fmtDate(t.scheduledDate!) == filterDateFormatted));
    }
    if (_fltTime != null) {
      final filterTime = DateFormat('HH:mm').format(_fltTime!);
      it = it.where((t) =>
          t.scheduledTime != null &&
          DateFormat('HH:mm').format(t.scheduledTime!) == filterTime);
    }
    if (_fltCompleted != null) {
      it = it.where((t) => t.completed == _fltCompleted);
    }
    if (_fltRepeat != null) {
      it = it.where((t) {
        final r = (t.repeatRule ?? '').trim();
        if (r.isEmpty) return false;
        if (_fltRepeat == 'Weekly') return r.startsWith('Weekly');
        return r == _fltRepeat;
      });
    }
    if (_fltReminder != null) {
      it = it.where((t) => t.hasNotification == _fltReminder);
    }
    return it.toList();
  }

  Future<void> _toggle(Todo todo, TodoProvider todoProvider) async {
    await todoProvider.toggleTodoStatus(todo);
  }

  Future<void> _delete(Todo todo, TodoProvider todoProvider) async {
    await todoProvider.deleteTodo(todo.id);
  }

  void _openSettings() {
    Navigator.of(context).pushNamed('settings');
  }

  double verticalPadding(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.04;
  double horizontalPadding(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.05;

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _fltDate ?? now,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 5),
                helpText: 'Select date',
              );
              if (picked != null) setSheetState(() => _fltDate = picked);
            }

            Future<void> pickTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _fltTime != null
                    ? TimeOfDay.fromDateTime(_fltTime!)
                    : TimeOfDay.now(),
              );
              if (picked != null) {
                final now = DateTime.now();
                setSheetState(() {
                  _fltTime = DateTime(
                      now.year, now.month, now.day, picked.hour, picked.minute);
                });
              }
            }

            Widget chip(String label, bool selected, VoidCallback onTap) {
              final bg = selected ? darkGrey : lightGrey;
              final fg = selected ? Colors.white : darkGrey;
              final borderColor = selected ? darkGrey : borderGrey;

              return Material(
                color: bg,
                shape: StadiumBorder(
                    side: BorderSide(color: borderColor)),
                child: InkWell(
                  onTap: onTap,
                  customBorder: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text(label, style: chipTextStyle.copyWith(color: fg)),
                  ),
                ),
              );
            }

            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: borderGrey,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Filter Options', style: headline1Style.copyWith(fontSize: 22)),
                      const SizedBox(height: 24),
                      Text('Date & Time', style: subtitle1Style),
                      const SizedBox(height: 16),
                      PickerField(
                        iconAsset: 'assets/calendar.svg',
                        hint: 'Set date',
                        valueText: _fltDate != null ? _fmtDate(_fltDate!) : null,
                        onTap: pickDate,
                        onClear: _fltDate != null
                            ? () => setSheetState(() => _fltDate = null)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      PickerField(
                        iconAsset: 'assets/clock.svg',
                        hint: 'Set time',
                        valueText: _fltTime != null ? _fmtTime(_fltTime!) : null,
                        onTap: pickTime,
                        onClear: _fltTime != null
                            ? () => setSheetState(() => _fltTime = null)
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Text('Completion Status', style: subtitle1Style),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          chip('Completed', _fltCompleted == true,
                              () => setSheetState(() => _fltCompleted = true)),
                          chip('Incomplete', _fltCompleted == false,
                              () => setSheetState(() => _fltCompleted = false)),
                          chip('Any', _fltCompleted == null,
                              () => setSheetState(() => _fltCompleted = null)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Repeat', style: subtitle1Style),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          chip('Daily', _fltRepeat == 'Daily',
                              () => setSheetState(() => _fltRepeat = 'Daily')),
                          chip('Weekly', _fltRepeat == 'Weekly',
                              () => setSheetState(() => _fltRepeat = 'Weekly')),
                          chip(
                              'Monthly',
                              _fltRepeat == 'Monthly',
                              () =>
                                  setSheetState(() => _fltRepeat = 'Monthly')),
                          chip('No repeat', _fltRepeat == null,
                              () => setSheetState(() => _fltRepeat = null)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Reminders', style: subtitle1Style),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          chip('On', _fltReminder == true,
                              () => setSheetState(() => _fltReminder = true)),
                          chip('Off', _fltReminder == false,
                              () => setSheetState(() => _fltReminder = false)),
                          chip('Any', _fltReminder == null,
                              () => setSheetState(() => _fltReminder = null)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: chipTextStyle.copyWith(fontSize: 16, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(
                                () {});
                          },
                          child: const Text('Apply Filter'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setSheetState(() {
                              _fltDate = null;
                              _fltTime = null;
                              _fltCompleted = null;
                              _fltRepeat = null;
                              _fltReminder = null;
                            });
                            setState(() {});
                          },
                          child: Text('Clear selections', style: chipTextStyle.copyWith(color: mediumGrey)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<Box<Todo>>(
        valueListenable: todoProvider.listenableTodoBox,
        builder: (context, box, _) {
          final allTodos = todoProvider.todos;
          final filteredTodos = _getFilteredTodos(allTodos);

          return CustomScrollView(
            slivers: [
              // HEADER BAR
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                toolbarHeight: 80, // Increased toolbar height for a spacious feel
                titleSpacing: 0, // Remove default title spacing
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      SvgPicture.asset('assets/trans_logo.svg', height: 36), // Larger logo
                      // Settings Button
                      IconButton(
                        iconSize: 32, // Larger icon
                        splashRadius: 32,
                        tooltip: 'Settings',
                        onPressed: _openSettings,
                        icon: const Icon(Icons.settings_outlined, color: darkGrey), // Changed icon
                      ),
                    ],
                  ),
                ),
              ),

              // "Today" Title and Filter Button section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding(context),
                    12, // Reduced top padding
                    horizontalPadding(context),
                    24, // Increased bottom padding
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Tugas', // Changed title
                        style: headline1Style,
                      ),
                      _FilterChipButton(
                        label: 'Filter',
                        onTap: _openFilterSheet,
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),

              // Task list (uses filtered todos)
              SliverList.builder( // Changed to builder as we now control padding within the item
                itemCount: filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = filteredTodos[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding(context),
                      vertical: 8, // Padding between cards
                    ),
                    child: Dismissible(
                      key: ValueKey(todo.id),
                      direction: DismissDirection.endToStart,
                      background: const SizedBox.shrink(),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12), // Match card radius
                        ),
                        child: Icon(Icons.delete_forever_outlined, color: accentRed, size: 30), // Changed icon
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Task?'),
                            content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: accentRed),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ) ?? false;
                      },
                      onDismissed: (_) =>
                          _delete(todo, todoProvider),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            'edit_task',
                            arguments: todo,
                          );
                        },
                        child: _TaskCard( // Using new _TaskCard widget
                            todo: todo,
                            onToggle: () => _toggle(todo, todoProvider)),
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, 'add_task');
        },
        backgroundColor: darkGrey,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.onTap,
    this.height = 40,
  });

  final String label;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: lightGrey,
      shape: StadiumBorder(side: BorderSide(color: borderGrey)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: chipTextStyle.copyWith(color: darkGrey),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/filter.svg',
                  height: 18,
                  width: 18,
                  colorFilter:
                      const ColorFilter.mode(darkGrey, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// NEW WIDGET: _TaskCard to encapsulate the task item's visual style
class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.todo,
    required this.onToggle,
  });

  final Todo todo;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDone = todo.completed;

    final titleStyle = body1Style.copyWith(
      decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
      color: isDone ? mediumGrey : darkGrey,
    );

    final descriptionStyle = body2Style.copyWith(
      color: isDone ? mediumGrey.withOpacity(0.7) : mediumGrey,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDone ? lightGrey.withOpacity(0.6) : Colors.white, // Lighter background for completed tasks
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDone ? borderGrey.withOpacity(0.5) : borderGrey),
        boxShadow: isDone
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16), // Padding inside the card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CircleCheck(completed: isDone, onTap: onToggle),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  todo.title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if ((todo.description ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 4, right: 8), // Align with title text
              child: Text(
                todo.description!,
                style: descriptionStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (!isDone) // Show meta info only if incomplete
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 12), // Align with title text
              child: _TaskMeta(todo: todo),
            ),
        ],
      ),
    );
  }
}


class _TaskMeta extends StatelessWidget {
  const _TaskMeta({required this.todo});
  final Todo todo;

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yy').format(d);
  String _fmtTime(DateTime dt) => DateFormat('h:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final List<Widget> meta = [];
    if (todo.scheduledTime != null) {
      meta.add(_Meta(
          icon: Icons.access_time,
          text: _fmtTime(todo.scheduledTime!),
          style: metaStyle));
    }
    if (todo.scheduledDate != null) {
      meta.add(_Meta(
          icon: Icons.event_note,
          text: _fmtDate(todo.scheduledDate!),
          style: metaStyle));
    }
    if (todo.hasNotification) {
      meta.add(_Meta(icon: Icons.notifications_none, text: '', style: metaStyle));
    }
    if ((todo.repeatRule ?? '').isNotEmpty) {
      meta.add(
          _Meta(icon: Icons.repeat, text: todo.repeatRule!, style: metaStyle));
    }

    if (meta.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 12, runSpacing: 6, children: meta);
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, required this.style});
  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: style.color),
        if (text.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(text, style: style),
        ],
      ],
    );
  }
}

class _CircleCheck extends StatelessWidget {
  const _CircleCheck({required this.completed, required this.onTap});
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      customBorder: const CircleBorder(),
      radius: 24,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: completed ? primaryBlue : borderGrey,
            width: 2,
          ),
          color: completed ? primaryBlue : Colors.white,
        ),
        child: completed
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}
// --- END OF FILE lib/screens/home_page.dart (MODIFIED - NEW LAYOUT) ---