// --- START OF FILE lib/widgets/common_form_widgets.dart ---
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Import tema dari lokasi yang sudah ditentukan
import 'package:doable_todo_list_app/theme/app_theme.dart';

/* ================= Reusable widgets ================= */

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: subtitle1Style,
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      style: body2Style.copyWith(color: darkGrey),
    );
  }
}

class ReminderButton extends StatelessWidget {
  const ReminderButton({super.key, required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? primaryBlue : lightGrey;
    final fg = enabled ? Colors.white : darkGrey;
    final borderColor = enabled ? primaryBlue : borderGrey;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: bg,
        shape: StadiumBorder(
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set Reminder',
                  style: chipTextStyle.copyWith(color: fg),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  enabled ? 'assets/bell_white.svg' : 'assets/bell.svg',
                  height: 18,
                  width: 18,
                  colorFilter: enabled
                      ? null
                      : const ColorFilter.mode(darkGrey, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RepeatChip extends StatelessWidget {
  const RepeatChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? darkGrey : lightGrey;
    final fg = selected ? Colors.white : darkGrey;
    final borderColor = selected ? darkGrey : borderGrey;

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: borderColor)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: chipTextStyle.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}

class WeekdayChip extends StatelessWidget {
  const WeekdayChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? darkGrey : lightGrey;
    final fg = selected ? Colors.white : darkGrey;
    final borderColor = selected ? darkGrey : borderGrey;

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: borderColor)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: chipTextStyle.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}

class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.hint,
    required this.iconAsset,
    required this.onTap,
    this.valueText,
    this.onClear,
  });

  final String hint;
  final String iconAsset;
  final String? valueText;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasValue = valueText != null && valueText!.isNotEmpty;

    return Material(
      color: lightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderGrey),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                height: 20,
                width: 20,
                colorFilter:
                const ColorFilter.mode(darkGrey, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue ? valueText! : hint,
                  style: body2Style.copyWith(
                    color: hasValue ? darkGrey : mediumGrey,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (hasValue && onClear != null)
                IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close, size: 20, color: mediumGrey),
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
// --- END OF FILE lib/widgets/common_form_widgets.dart ---