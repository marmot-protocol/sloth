import 'package:flutter/material.dart';
import 'package:whitenoise_widgetbook/utils/format_datetime_for_display.dart';
import 'package:widgetbook/widgetbook.dart';

enum _DateTimeOption {
  now,
  minutes30,
  hours5,
  yesterday,
  days3,
  weeks2,
  years2,
  custom,
}

DateTime _dateTimeFromOption(_DateTimeOption option) {
  final now = DateTime.now();
  switch (option) {
    case _DateTimeOption.now:
      return now;
    case _DateTimeOption.minutes30:
      return now.subtract(const Duration(minutes: 30));
    case _DateTimeOption.hours5:
      return now.subtract(const Duration(hours: 5));
    case _DateTimeOption.yesterday:
      return now.subtract(const Duration(days: 1, hours: 14));
    case _DateTimeOption.days3:
      return now.subtract(const Duration(days: 3));
    case _DateTimeOption.weeks2:
      return now.subtract(const Duration(days: 14));
    case _DateTimeOption.years2:
      return now.subtract(const Duration(days: 730));
    case _DateTimeOption.custom:
      return now;
  }
}

const _dateTimeOptions = [
  (_DateTimeOption.now, 'Now'),
  (_DateTimeOption.minutes30, '30 min ago'),
  (_DateTimeOption.hours5, '5 hours ago'),
  (_DateTimeOption.yesterday, 'Yesterday'),
  (_DateTimeOption.days3, '3 days ago'),
  (_DateTimeOption.weeks2, '2 weeks ago'),
  (_DateTimeOption.years2, '2 years ago'),
  (_DateTimeOption.custom, 'Enter another date time'),
];

final _datetimeSelectionCodec = FieldCodec<String>(
  toParam: (String v) => v,
  toValue: (String? p) => p,
);

const _defaultOption = _DateTimeOption.hours5;

_DateTimeOption _optionFromName(String name) => _DateTimeOption.values
    .firstWhere((e) => e.name == name, orElse: () => _defaultOption);

class _KindField extends Field<String> {
  _KindField({
    required super.name,
    required super.initialValue,
    required super.defaultValue,
  }) : super(type: FieldType.string, codec: _datetimeSelectionCodec);

  @override
  Widget toWidget(BuildContext context, String group, String? value) {
    final kind = value ?? _defaultOption.name;
    final currentOption = kind == 'custom'
        ? _DateTimeOption.custom
        : _optionFromName(kind);

    return DropdownButtonFormField<_DateTimeOption>(
      initialValue: currentOption,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _dateTimeOptions
          .map(
            (option) =>
                DropdownMenuItem(value: option.$1, child: Text(option.$2)),
          )
          .toList(),
      onChanged: (_DateTimeOption? option) {
        if (option == null) return;
        updateField(
          context,
          group,
          option == _DateTimeOption.custom ? 'custom' : option.name,
        );
      },
    );
  }
}

class _ValueField extends Field<String> {
  _ValueField({
    required super.name,
    required super.initialValue,
    required super.defaultValue,
    required this.customInitialDateTime,
  }) : super(type: FieldType.string, codec: _datetimeSelectionCodec);

  final DateTime customInitialDateTime;

  @override
  Widget toWidget(BuildContext context, String group, String? value) {
    final state = WidgetbookState.of(context);
    final groupMap = FieldCodec.decodeQueryGroup(state.queryParams[group]);
    final kind = groupMap['kind'] ?? _defaultOption.name;
    if (kind != 'custom') return const SizedBox.shrink();

    final currentDateTime = (value != null && value.isNotEmpty)
        ? (DateTime.tryParse(value) ?? customInitialDateTime)
        : customInitialDateTime;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        key: ValueKey(currentDateTime.toIso8601String()),
        initialValue: formatDateTimeForDisplay(currentDateTime),
        readOnly: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Pick date & time',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: currentDateTime,
                firstDate: DateTime(1970),
                lastDate: DateTime.now(),
              );
              if (date == null || !context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(currentDateTime),
              );
              if (time == null || !context.mounted) return;
              final dt = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              updateField(context, group, dt.toIso8601String());
            },
          ),
        ),
      ),
    );
  }
}

class CustomDateTimeKnob extends Knob<DateTime> {
  CustomDateTimeKnob({required super.label, required super.initialValue});

  static const _kindFieldName = 'kind';
  static const _valueFieldName = 'value';

  @override
  List<Field> get fields => [
    _KindField(
      name: _kindFieldName,
      initialValue: _defaultOption.name,
      defaultValue: _defaultOption.name,
    ),
    _ValueField(
      name: _valueFieldName,
      initialValue: initialValue.toIso8601String(),
      defaultValue: initialValue.toIso8601String(),
      customInitialDateTime: initialValue,
    ),
  ];

  @override
  DateTime valueFromQueryGroup(Map<String, String> group) {
    final kind = valueOf<String>(_kindFieldName, group) ?? _defaultOption.name;
    final value = valueOf<String>(_valueFieldName, group);
    if (kind == 'custom' && value != null && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return initialValue;
      }
    }
    return _dateTimeFromOption(_optionFromName(kind));
  }
}

extension CustomDateTimeKnobBuilder on KnobsBuilder {
  DateTime customDateTime({required String label, DateTime? initialValue}) =>
      onKnobAdded(
        CustomDateTimeKnob(
          label: label,
          initialValue: initialValue ?? _dateTimeFromOption(_defaultOption),
        ),
      )!;
}
