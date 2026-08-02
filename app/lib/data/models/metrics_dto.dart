import 'package:json_annotation/json_annotation.dart';
import 'package:qwe1/domain/entities/metrics.dart';

part 'metrics_dto.g.dart';

@JsonSerializable()
class MetricsDto {
  final String timestamp;
  final HostInfoDto host;

  MetricsDto({required this.timestamp, required this.host});

  factory MetricsDto.fromJson(Map<String, dynamic> json) => _$MetricsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MetricsDtoToJson(this);

  HostMetrics toEntity() => HostMetrics(
        timestamp: DateTime.parse(timestamp),
        host: host.toEntity(),
      );
}

@JsonSerializable()
class HostInfoDto {
  final String hostname;
  final int uptimeSeconds;
  @JsonKey(name: 'load', defaultValue: [])
  final List<double> load;
  final CpuMetricsDto cpu;
  final MemoryMetricsDto memory;
  @JsonKey(name: 'disk', defaultValue: [])
  final List<DiskMetricsDto> disk;
  final NetworkMetricsDto network;
  @JsonKey(name: 'temp')
  final TempInfoDto temp;

  HostInfoDto({
    required this.hostname,
    required this.uptimeSeconds,
    List<double>? load,
    required this.cpu,
    required this.memory,
    List<DiskMetricsDto>? disk,
    required this.network,
    required this.temp,
  })  : load = load ?? [],
        disk = disk ?? [];

  factory HostInfoDto.fromJson(Map<String, dynamic> json) => _$HostInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HostInfoDtoToJson(this);

  HostInfo toEntity() => HostInfo(
        hostname: hostname,
        uptimeSeconds: uptimeSeconds,
        load: load,
        cpu: cpu.toEntity(),
        memory: memory.toEntity(),
        disk: disk.map((e) => e.toEntity()).toList(),
        network: network.toEntity(),
        sensors: temp.sensors.map((e) => e.toEntity()).toList(),
      );
}

@JsonSerializable()
class TempInfoDto {
  @JsonKey(name: 'sensors', defaultValue: [])
  final List<TempSensorDto> sensors;

  TempInfoDto({List<TempSensorDto>? sensors}) : sensors = sensors ?? [];

  factory TempInfoDto.fromJson(Map<String, dynamic> json) => _$TempInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TempInfoDtoToJson(this);
}

@JsonSerializable()
class CpuMetricsDto {
  final double percent;
  final List<double> perCore;

  CpuMetricsDto({required this.percent, this.perCore = const []});

  factory CpuMetricsDto.fromJson(Map<String, dynamic> json) => _$CpuMetricsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CpuMetricsDtoToJson(this);

  CpuMetrics toEntity() => CpuMetrics(percent: percent, perCore: perCore);
}

@JsonSerializable()
class MemoryMetricsDto {
  final int total;
  final int used;
  final double percent;
  final double swapPercent;

  MemoryMetricsDto({
    required this.total,
    required this.used,
    required this.percent,
    this.swapPercent = 0.0,
  });

  factory MemoryMetricsDto.fromJson(Map<String, dynamic> json) => _$MemoryMetricsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MemoryMetricsDtoToJson(this);

  MemoryMetrics toEntity() => MemoryMetrics(
        total: total,
        used: used,
        percent: percent,
        swapPercent: swapPercent,
      );
}

@JsonSerializable()
class DiskMetricsDto {
  final String mount;
  final int total;
  final int used;
  final double percent;

  DiskMetricsDto({
    required this.mount,
    required this.total,
    required this.used,
    required this.percent,
  });

  factory DiskMetricsDto.fromJson(Map<String, dynamic> json) => _$DiskMetricsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DiskMetricsDtoToJson(this);

  DiskMetrics toEntity() => DiskMetrics(
        mount: mount,
        total: total,
        used: used,
        percent: percent,
      );
}

@JsonSerializable()
class NetworkMetricsDto {
  final double rxBytesPerSec;
  final double txBytesPerSec;

  NetworkMetricsDto({this.rxBytesPerSec = 0.0, this.txBytesPerSec = 0.0});

  factory NetworkMetricsDto.fromJson(Map<String, dynamic> json) => _$NetworkMetricsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkMetricsDtoToJson(this);

  NetworkMetrics toEntity() => NetworkMetrics(
        rxBytesPerSec: rxBytesPerSec,
        txBytesPerSec: txBytesPerSec,
      );
}

@JsonSerializable()
class TempSensorDto {
  final String name;
  final double celsius;

  TempSensorDto({required this.name, required this.celsius});

  factory TempSensorDto.fromJson(Map<String, dynamic> json) => _$TempSensorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TempSensorDtoToJson(this);

  TempSensor toEntity() => TempSensor(name: name, celsius: celsius);
}
