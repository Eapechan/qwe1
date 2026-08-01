// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetricsDto _$MetricsDtoFromJson(Map<String, dynamic> json) => MetricsDto(
      timestamp: json['timestamp'] as String,
      host: HostInfoDto.fromJson(json['host'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MetricsDtoToJson(MetricsDto instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'host': instance.host,
    };

HostInfoDto _$HostInfoDtoFromJson(Map<String, dynamic> json) => HostInfoDto(
      hostname: json['hostname'] as String,
      uptimeSeconds: (json['uptimeSeconds'] as num).toInt(),
      load: (json['load'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      cpu: CpuMetricsDto.fromJson(json['cpu'] as Map<String, dynamic>),
      memory: MemoryMetricsDto.fromJson(json['memory'] as Map<String, dynamic>),
      disk: (json['disk'] as List<dynamic>?)
              ?.map((e) => DiskMetricsDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      network:
          NetworkMetricsDto.fromJson(json['network'] as Map<String, dynamic>),
      sensors: (json['sensors'] as List<dynamic>?)
              ?.map((e) => TempSensorDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HostInfoDtoToJson(HostInfoDto instance) =>
    <String, dynamic>{
      'hostname': instance.hostname,
      'uptimeSeconds': instance.uptimeSeconds,
      'load': instance.load,
      'cpu': instance.cpu,
      'memory': instance.memory,
      'disk': instance.disk,
      'network': instance.network,
      'sensors': instance.sensors,
    };

CpuMetricsDto _$CpuMetricsDtoFromJson(Map<String, dynamic> json) =>
    CpuMetricsDto(
      percent: (json['percent'] as num).toDouble(),
      perCore: (json['perCore'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CpuMetricsDtoToJson(CpuMetricsDto instance) =>
    <String, dynamic>{
      'percent': instance.percent,
      'perCore': instance.perCore,
    };

MemoryMetricsDto _$MemoryMetricsDtoFromJson(Map<String, dynamic> json) =>
    MemoryMetricsDto(
      total: (json['total'] as num).toInt(),
      used: (json['used'] as num).toInt(),
      percent: (json['percent'] as num).toDouble(),
      swapPercent: (json['swapPercent'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$MemoryMetricsDtoToJson(MemoryMetricsDto instance) =>
    <String, dynamic>{
      'total': instance.total,
      'used': instance.used,
      'percent': instance.percent,
      'swapPercent': instance.swapPercent,
    };

DiskMetricsDto _$DiskMetricsDtoFromJson(Map<String, dynamic> json) =>
    DiskMetricsDto(
      mount: json['mount'] as String,
      total: (json['total'] as num).toInt(),
      used: (json['used'] as num).toInt(),
      percent: (json['percent'] as num).toDouble(),
    );

Map<String, dynamic> _$DiskMetricsDtoToJson(DiskMetricsDto instance) =>
    <String, dynamic>{
      'mount': instance.mount,
      'total': instance.total,
      'used': instance.used,
      'percent': instance.percent,
    };

NetworkMetricsDto _$NetworkMetricsDtoFromJson(Map<String, dynamic> json) =>
    NetworkMetricsDto(
      rxBytesPerSec: (json['rxBytesPerSec'] as num?)?.toDouble() ?? 0.0,
      txBytesPerSec: (json['txBytesPerSec'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$NetworkMetricsDtoToJson(NetworkMetricsDto instance) =>
    <String, dynamic>{
      'rxBytesPerSec': instance.rxBytesPerSec,
      'txBytesPerSec': instance.txBytesPerSec,
    };

TempSensorDto _$TempSensorDtoFromJson(Map<String, dynamic> json) =>
    TempSensorDto(
      name: json['name'] as String,
      celsius: (json['celsius'] as num).toDouble(),
    );

Map<String, dynamic> _$TempSensorDtoToJson(TempSensorDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'celsius': instance.celsius,
    };
