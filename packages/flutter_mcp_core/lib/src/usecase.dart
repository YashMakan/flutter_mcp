import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

// Base class for Use Cases
// P = Params, T = Type (Return Value)
abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params); // Using Either for error handling
}

// Use case without parameters
abstract class UseCaseWithoutParams<T> {
  Future<Either<Failure, T>> call();
}

// Specific use case for streams
abstract class StreamUseCase<T, P> {
  Stream<Either<Failure, T>> call(P params);
}


// Example NoParams class if needed often
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

// Example Failure class (in core/error/failures.dart)
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

class LogicFailure extends Failure {
  const LogicFailure(super.message);
}