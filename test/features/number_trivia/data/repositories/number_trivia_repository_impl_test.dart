import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/platform/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/data/sources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/sources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  mockNetworkInfo = MockNetworkInfo();
  mockLocalDataSource = MockLocalDataSource();
  mockRemoteDataSource = MockRemoteDataSource();
  repository = NumberTriviaRepositoryImpl(
    remoteDataSource: mockRemoteDataSource,
    localDataSource: mockLocalDataSource,
    networkInfo: mockNetworkInfo,
  );

  group('getConcreteNumberTrivia', () {
    // Data for the mocks and assertions
    const tNumber = 1;
    const tNumberTriviaModel =
        NumberTriviaModel(text: 'test text', number: tNumber);

    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check if device is online',
      () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    group('device is online', () {
      // This setUp applies only to the 'device is online' group
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        'Should cache the data when the call to remote data source is successful',
        () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(
              () => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenThrow(ServerException());
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });
  });
}
