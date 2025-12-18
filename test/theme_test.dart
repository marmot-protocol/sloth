import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme.dart';

void main() {
  group('lightTheme', () {
    test('has light brightness', () {
      expect(lightTheme.brightness, Brightness.light);
    });
  });

  group('darkTheme', () {
    test('has dark brightness', () {
      expect(darkTheme.brightness, Brightness.dark);
    });
  });
}
