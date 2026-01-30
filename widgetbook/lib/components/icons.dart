import 'package:flutter/material.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: WnIcon)
Widget wnIconUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: WnIcon(
        context.knobs.object.dropdown(
          label: 'Icon',
          options: WnIcons.values,
          initialOption: WnIcons.placeholder,
          labelBuilder: (value) => value.name,
        ),
        size: context.knobs.double.slider(
          label: 'Size',
          initialValue: 24,
          min: 12,
          max: 64,
        ),
        color: context.knobs.color(label: 'Color', initialValue: Colors.black),
      ),
    ),
  );
}

extension on WnIcons {
  String get name => toString().split('.').last;
}
