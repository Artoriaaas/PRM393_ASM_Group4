import '../utils/app_failure.dart';

/// Generic UI load state pattern specified in architecture.md section 6
sealed class LoadState<T> {
  const LoadState();

  const factory LoadState.initial() = LoadStateInitial<T>;
  const factory LoadState.loading({T? previousData}) = LoadStateLoading<T>;
  const factory LoadState.empty({String? message}) = LoadStateEmpty<T>;
  const factory LoadState.data({
    required T data,
    DateTime? updatedAt,
    bool isStale,
  }) = LoadStateData<T>;
  const factory LoadState.error({required AppFailure failure, T? cachedData}) =
      LoadStateError<T>;

  bool get isLoading => this is LoadStateLoading<T>;
  bool get isEmpty => this is LoadStateEmpty<T>;
  bool get hasData => this is LoadStateData<T>;
  bool get isError => this is LoadStateError<T>;

  T? get dataOrNull => switch (this) {
    LoadStateData<T>(data: final d) => d,
    LoadStateLoading<T>(previousData: final d) => d,
    LoadStateError<T>(cachedData: final d) => d,
    _ => null,
  };

  R when<R>({
    required R Function() initial,
    required R Function(T? previousData) loading,
    required R Function(String? message) empty,
    required R Function(T data, DateTime? updatedAt, bool isStale) data,
    required R Function(AppFailure failure, T? cachedData) error,
  }) {
    return switch (this) {
      LoadStateInitial<T>() => initial(),
      LoadStateLoading<T>(previousData: final p) => loading(p),
      LoadStateEmpty<T>(message: final m) => empty(m),
      LoadStateData<T>(data: final d, updatedAt: final u, isStale: final s) =>
        data(d, u, s),
      LoadStateError<T>(failure: final f, cachedData: final c) => error(f, c),
    };
  }
}

final class LoadStateInitial<T> extends LoadState<T> {
  const LoadStateInitial();
}

final class LoadStateLoading<T> extends LoadState<T> {
  const LoadStateLoading({this.previousData});
  final T? previousData;
}

final class LoadStateEmpty<T> extends LoadState<T> {
  const LoadStateEmpty({this.message});
  final String? message;
}

final class LoadStateData<T> extends LoadState<T> {
  const LoadStateData({
    required this.data,
    this.updatedAt,
    this.isStale = false,
  });

  final T data;
  final DateTime? updatedAt;
  final bool isStale;
}

final class LoadStateError<T> extends LoadState<T> {
  const LoadStateError({required this.failure, this.cachedData});

  final AppFailure failure;
  final T? cachedData;
}
