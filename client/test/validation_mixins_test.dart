import 'package:flutter_test/flutter_test.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';

void main() {
  group("ValidationMixin class", () {
    group("Email validation", () {
      test('email "" should be false', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validateEmail(""), false);
      });
      test('email "test123@" should be false', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validateEmail("test123@"), false);
      });

      test('email "dimitrihauet@gmail.com" should be true', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validateEmail("dimitrihauet@gmail.com"), true);
      });
      test('email "dimitrihauet@gmail" should be false', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validateEmail("dimitrihauet@gmail"), false);
      });
    });
    group("Password validation", () {
      test('password "123123" should be false', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validatePassword("123123"), false);
      });
      test('password "" should be false', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validatePassword(""), false);
      });
      test('password "azerty59" should be false', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validatePassword("azerty59"), false);
      });
      test('password "Azertyu59456" should be false', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validatePassword("Azertyu59456"), false);
      });
      test('password "Azerty59460#Q" should be true', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validatePassword("Azerty59460#Q"), true);
      });
      test('password "XsV2Sp7fQW&Q!KOcc!KN" should be true', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validatePassword("XsV2Sp7fQW&Q!KOcc!KN"), true);
      });
    });

    group('Pseudo validation', () {
      test('pseudo "" should be false', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validatePseudo(""), false);
      });
      test('pseudo "ziakor4564" should be true', () {
        final ValidationMixin validationMixin = ValidationMixin();
        expect(validationMixin.validatePseudo("ziakor4564"), true);
      });
    });
  });
}
