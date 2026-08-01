import 'package:freezed_annotation/freezed_annotation.dart';

part 'metrics.freezed.dart';

@freezed
class HostMetrics with _$HostMetrics {
  const factory HostMetrics({
    required DateTime timestamp,
    required HostInfo host,
  }) = _HostMetrics;
}

@freezed
class HostInfo with _$HostInfo {
  const factory HostInfo({
    required String hostname,
    required int uptimeSeconds,
    @Default([]) List<double> load,
    required CpuMetrics cpu,
    required MemoryMetrics memory,
    @Default([]) List<DiskMetrics> disk,
    required NetworkMetrics network,
    @Default([]) List<TempSensor> sensors,
  }) = _HostInfo;
}

@freezed
class CpuMetrics with _$CpuMetrics {
  const factory CpuMetrics({
    required double percent,
    @Default([]) List<double> perCore,
  }) = _CpuMetrics;
}

@freezed
class MemoryMetrics with _$MemoryMetrics {
  const factory MemoryMetrics({
    required int total,
    required int used,
    required double percent,
    @Default(0.0) double swapPercent,
  }) = _MemoryMetrics;
}

@freezed
class DiskMetrics with _$DiskMetrics {
  const factory DiskMetrics({
    required String mount,
    required int total,
    required int used,
    required double percent,
  }) = _DiskMetrics;
}

@freezed
class NetworkMetrics with _$NetworkMetrics {
  const factory NetworkMetrics({
    @Default(0.0) double rxBytesPerSec,
    @Default(0.0) double txBytesPerSec,
  }) = _NetworkMetrics;
}

@freezed
class TempSensor with _$TempSensor {
  const factory TempSensor({
    required String name,
    required double celsius,
  }) = _TempSensor;
}
