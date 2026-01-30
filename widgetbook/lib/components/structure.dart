import 'package:flutter/material.dart';
import 'package:sloth/widgets/wn_overlay.dart';
import 'package:sloth/widgets/wn_scroll_edge_effect.dart';
import 'package:sloth/widgets/wn_separator.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: WnSeparator)
Widget wnSeparatorUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(32.0),
    child: Center(
      child: Container(
        width: 300,
        height: 300,
        color: Colors.white,
        child: Center(
          child: WnSeparator(
            orientation: context.knobs.object.dropdown(
              label: 'Orientation',
              options: WnSeparatorOrientation.values,
              initialOption: WnSeparatorOrientation.horizontal,
              labelBuilder: (value) => value.name,
            ),
            indent: context.knobs.double.slider(
              label: 'Indent',
              initialValue: 0,
              min: 0,
              max: 100,
            ),
            endIndent: context.knobs.double.slider(
              label: 'End Indent',
              initialValue: 0,
              min: 0,
              max: 100,
            ),
            color: context.knobs.color(
              label: 'Color',
              initialValue: Colors.grey.shade300,
            ),
          ),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: WnOverlay)
Widget wnOverlayUseCase(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          // Background content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Background Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Overlay
          WnOverlay(
            sigmaX: context.knobs.double.slider(
              label: 'Sigma X',
              initialValue: 5,
              min: 0,
              max: 20,
            ),
            sigmaY: context.knobs.double.slider(
              label: 'Sigma Y',
              initialValue: 5,
              min: 0,
              max: 20,
            ),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: WnScrollEdgeEffect)
Widget wnScrollEdgeEffectUseCase(BuildContext context) {
  final type = context.knobs.object.dropdown(
    label: 'Type',
    options: ScrollEdgeEffectType.values,
    initialOption: ScrollEdgeEffectType.canvas,
    labelBuilder: (value) => value.name,
  );

  final position = context.knobs.object.dropdown(
    label: 'Position',
    options: ScrollEdgePosition.values,
    initialOption: ScrollEdgePosition.top,
    labelBuilder: (value) => value.name,
  );

  final color = context.knobs.color(label: 'Color', initialValue: Colors.white);

  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 48,
    min: 0,
    max: 100,
  );

  Widget edgeEffect;
  switch (type) {
    case ScrollEdgeEffectType.canvas:
      if (position == ScrollEdgePosition.top) {
        edgeEffect = WnScrollEdgeEffect.canvasTop(color: color, height: height);
      } else {
        edgeEffect = WnScrollEdgeEffect.canvasBottom(
          color: color,
          height: height,
        );
      }
      break;
    case ScrollEdgeEffectType.slate:
      if (position == ScrollEdgePosition.top) {
        edgeEffect = WnScrollEdgeEffect.slateTop(color: color, height: height);
      } else {
        edgeEffect = WnScrollEdgeEffect.slateBottom(
          color: color,
          height: height,
        );
      }
      break;
    case ScrollEdgeEffectType.dropdown:
      if (position == ScrollEdgePosition.top) {
        edgeEffect = WnScrollEdgeEffect.dropdownTop(
          color: color,
          height: height,
        );
      } else {
        edgeEffect = WnScrollEdgeEffect.dropdownBottom(
          color: color,
          height: height,
        );
      }
      break;
  }

  return Center(
    child: SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          Container(color: Colors.blue.shade100),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) =>
                ListTile(title: Text('Item $index')),
          ),
          edgeEffect,
        ],
      ),
    ),
  );
}

extension on WnSeparatorOrientation {
  String get name => toString().split('.').last;
}

extension on ScrollEdgeEffectType {
  String get name => toString().split('.').last;
}

extension on ScrollEdgePosition {
  String get name => toString().split('.').last;
}
