import 'package:geofence_service/models/geofence_radius.dart';
import 'package:geofence_service/models/geofence_status.dart';

/// A model representing a geofence.
class Geofence {
  /// Identifier for [Geofence].
  final String id;

  /// City name for [Geofence].
  final String name;

  /// Custom data for [Geofence].
  final dynamic data;

  /// The latitude of geofence center.
  final double latitude;

  /// The longitude of geofence center.
  final double longitude;

  /// The radius of [Geofence].
  final List<GeofenceRadius> radius;

  /// Returns the status of [Geofence].
  GeofenceStatus get status => _getStatus();

  /// Returns the timestamp of [Geofence].
  DateTime? get timestamp => _getTimestamp();

  /// The remaining distance to the destination.
  double? _remainingDistance;

  /// Returns the remaining distance to the destination.
  double? get remainingDistance => _remainingDistance;

  /// Constructs an instance of [Geofence].
  Geofence({
    required this.id,
    required this.name,
    this.data,
    required this.latitude,
    required this.longitude,
    required this.radius,
  })  : assert(id.isNotEmpty),
        assert(radius.isNotEmpty);

  /// Returns the data fields of [Geofence] in JSON format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius.map((e) => e.toJson()).toList(),
      'status': status,
      'timestamp': timestamp,
      'remainingDistance': _remainingDistance
    };
  }

  /// Factory method to create a [Geofence] object from a JSON map.
  factory Geofence.fromJson(Map<String, dynamic> json) {
    // Extract values from the JSON map
    final id = json['id'] as String;
    final name = json['name'] as String;
    final data = json['data'];
    final latitude = json['latitude'] as double;
    final longitude = json['longitude'] as double;

    // Extract radius data as a List<GeofenceRadius>
    final radiusList = json['radius'] as List<dynamic>;
    final radius = radiusList.map((radiusJson) {
      return GeofenceRadius.fromJson(radiusJson as Map<String, dynamic>);
    }).toList();

    // Create and return a Geofence object
    return Geofence(
      id: id,
      name: name,
      data: data,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

  /// Update the remaining distance of [Geofence].
  void updateRemainingDistance(double distance) {
    if (distance < 0.0) _remainingDistance = 0.0;
    _remainingDistance = distance;
  }

  /// Gets the status of [Geofence].
  GeofenceStatus _getStatus() {
    final innerRadius = radius.where((e) => e.status != GeofenceStatus.EXIT);
    final dwellRadius =
        innerRadius.where((e) => e.status == GeofenceStatus.DWELL);

    if (innerRadius.isNotEmpty) {
      return dwellRadius.isNotEmpty
          ? GeofenceStatus.DWELL
          : GeofenceStatus.ENTER;
    } else {
      return GeofenceStatus.EXIT;
    }
  }

  /// Gets the timestamp of [Geofence].
  DateTime? _getTimestamp() {
    final timestampList = <DateTime>[];
    DateTime? timestamp;
    for (var i = 0; i < radius.length; i++) {
      timestamp = radius[i].timestamp;
      if (timestamp != null) timestampList.add(timestamp);
    }

    timestampList.sort((a, b) => a.compareTo(b));
    if (timestampList.isEmpty) return null;

    if (_getStatus() != GeofenceStatus.EXIT) {
      return timestampList.first;
    } else {
      return timestampList.last;
    }
  }
}
