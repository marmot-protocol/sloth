import 'package:flutter/material.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: WnButton)
Widget wnButtonUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: WnButton(
        text: context.knobs.string(label: 'Text', initialValue: 'Button'),
        type: context.knobs.object.dropdown(
          label: 'Type',
          options: WnButtonType.values,
          initialOption: WnButtonType.primary,
          labelBuilder: (value) => value.name,
        ),
        size: context.knobs.object.dropdown(
          label: 'Size',
          options: WnButtonSize.values,
          initialOption: WnButtonSize.large,
          labelBuilder: (value) => value.name,
        ),
        loading: context.knobs.boolean(label: 'Loading', initialValue: false),
        disabled: context.knobs.boolean(label: 'Disabled', initialValue: false),
        leadingIcon: context.knobs.objectOrNull.dropdown(
          label: 'Leading Icon',
          options: [
            WnIcons.addCircle,
            WnIcons.arrowLeft,
            WnIcons.checkmarkFilled,
            WnIcons.closeLarge,
          ],
          labelBuilder: (value) => value.name,
        ),
        trailingIcon: context.knobs.objectOrNull.dropdown(
          label: 'Trailing Icon',
          options: [
            WnIcons.arrowRight,
            WnIcons.chevronRight,
            WnIcons.information,
          ],
          labelBuilder: (value) => value.name,
        ),
        onPressed: () {},
      ),
    ),
  );
}

extension on WnIcons {
  String get name => toString().split('.').last;
}
