import 'package:flutter/material.dart';
import 'package:sloth/widgets/wn_callout.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: WnCallout)
Widget wnCalloutUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: WnCallout(
        title: context.knobs.string(
          label: 'Title',
          initialValue: 'Callout Title',
        ),
        description: context.knobs.stringOrNull(
          label: 'Description',
          initialValue: 'This is a description for the callout.',
        ),
        type: context.knobs.object.dropdown(
          label: 'Type',
          options: CalloutType.values,
          initialOption: CalloutType.neutral,
          labelBuilder: (value) => value.name,
        ),
        onDismiss:
            context.knobs.boolean(label: 'Dismissible', initialValue: false)
            ? () {}
            : null,
      ),
    ),
  );
}

extension on CalloutType {
  String get name => toString().split('.').last;
}
