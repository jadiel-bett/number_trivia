import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixture/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test');

  test('should be a subtype of NumberTrivia entity', () {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test('should return a valid model when the Json number is an integer', () {
      // arrange
      final Map<String, dynamic> jsonMap = jsonDecode(fixture("trivia.json"));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);
      // assets
      expect(result, tNumberTriviaModel);
    });

    test('should return a valid model when the Json number is a double', () {
      // arrange
      final Map<String, dynamic> jsonMap =
          jsonDecode(fixture("trivia_double.json"));
      // act
      final result = NumberTriviaModel.fromJson(jsonMap);
      // assets
      expect(result, tNumberTriviaModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tNumberTriviaModel.toJson();
      // assert
      final expectedMap = {"text": "Test", "number": 1};
      expect(result, expectedMap);
    });
  });
}
