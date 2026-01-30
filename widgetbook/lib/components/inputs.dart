import 'package:flutter/material.dart';
import 'package:sloth/widgets/wn_input.dart';
import 'package:sloth/widgets/wn_input_password.dart';
import 'package:sloth/widgets/wn_input_text_area.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: WnInput)
Widget wnInputUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: WnInput(
        placeholder: context.knobs.string(
          label: 'Placeholder',
          initialValue: 'Enter text...',
        ),
        label: context.knobs.stringOrNull(
          label: 'Label',
          initialValue: 'Label',
        ),
        helperText: context.knobs.stringOrNull(
          label: 'Helper Text',
          initialValue: 'This is helper text',
        ),
        errorText: context.knobs.stringOrNull(label: 'Error Text'),
        enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
        readOnly: context.knobs.boolean(
          label: 'Read Only',
          initialValue: false,
        ),
        size: context.knobs.object.dropdown(
          label: 'Size',
          options: WnInputSize.values,
          initialOption: WnInputSize.size56,
          labelBuilder: (value) => value.name,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Password', type: WnInputPassword)
Widget wnInputPasswordUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: WnInputPassword(
        placeholder: context.knobs.string(
          label: 'Placeholder',
          initialValue: 'Enter password...',
        ),
        label: context.knobs.stringOrNull(
          label: 'Label',
          initialValue: 'Password',
        ),
        helperText: context.knobs.stringOrNull(label: 'Helper Text'),
        errorText: context.knobs.stringOrNull(label: 'Error Text'),
        enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
        size: context.knobs.object.dropdown(
          label: 'Size',
          options: WnInputSize.values,
          initialOption: WnInputSize.size56,
          labelBuilder: (value) => value.name,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Text Area', type: WnInputTextArea)
Widget wnInputTextAreaUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: WnInputTextArea(
        placeholder: context.knobs.string(
          label: 'Placeholder',
          initialValue: 'Enter multiline text...',
        ),
        label: context.knobs.stringOrNull(
          label: 'Label',
          initialValue: 'Comments',
        ),
        helperText: context.knobs.stringOrNull(label: 'Helper Text'),
        errorText: context.knobs.stringOrNull(label: 'Error Text'),
        enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
        readOnly: context.knobs.boolean(
          label: 'Read Only',
          initialValue: false,
        ),
        size: context.knobs.object.dropdown(
          label: 'Size',
          options: WnInputSize.values,
          initialOption: WnInputSize.size56,
          labelBuilder: (value) => value.name,
        ),
        maxLines: context.knobs.int
            .slider(label: 'Max Lines', initialValue: 5, min: 1, max: 10)
            .toInt(),
      ),
    ),
  );
}
