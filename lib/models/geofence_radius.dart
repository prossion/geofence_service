import 'package:flutter_activity_recognition/models/activity.dart';
import 'package:geofence_service/models/geofence_status.dart';

/// A model representing the radius of [Geofence].
class GeofenceRadius {
  /// Identifier for [GeofenceRadius].
  final String id;

  /// Custom data for [GeofenceRadius].
  final dynamic data;

  /// The length of the radius in meters.
  /// The best result should be set between 100 and 150 meters in radius.
  /// If Wi-FI is available, it can be set up to 20~40m.
  final double length;

  /// The status of [GeofenceRadius].
  GeofenceStatus _status = GeofenceStatus.EXIT;

  /// Returns the status of [GeofenceRadius].
  GeofenceStatus get status => _status;

  /// The user activity when geofence status changes.
  Activity? _activity;

  /// Returns the user activity when geofence status changes.
  Activity? get activity => _activity;

  /// The passing speed when geofence status changes.
  double? _speed;

  /// Returns the passing speed when geofence status changes.
  double? get speed => _speed;

  /// The timestamp when geofence status changes.
  DateTime? _timestamp;

  /// Returns the timestamp when geofence status changes.
  DateTime? get timestamp => _timestamp;

  /// The remaining distance to the radius.
  double? _remainingDistance;

  /// Returns the remaining distance to the radius.
  double? get remainingDistance => _remainingDistance;

  /// Constructs an instance of [GeofenceRadius].
  GeofenceRadius({required this.id, this.data, required this.length})
      : assert(id.isNotEmpty),
        assert(length > 0.0);

  /// Returns the data fields of [GeofenceRadius] in JSON format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'length': length,
      'status': _status,
      'activity': _activity?.toJson(),
      'speed': _speed,
      'timestamp': _timestamp,
      'remainingDistance': _remainingDistance
    };
  }

  factory GeofenceRadius.fromJson(Map<String, dynamic> json) {
    // Extract values from the JSON map
    final id = json['id'] as String;
    final data = json['data'];
    final length = json['length'] as double;
    final statusString = json['status'] as String?;
    final activityJson = json['activity'] as Map<String, dynamic>?;
    final speed = json['speed'] as double?;
    final timestampString = json['timestamp'] as String?;
    final remainingDistance = json['remainingDistance'] as double?;

    // Parse status from the statusString
    GeofenceStatus status = GeofenceStatus.EXIT;
    if (statusString != null) {
      status = GeofenceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusString,
        orElse: () => GeofenceStatus.EXIT,
      );
    }

    // Parse activity from activityJson
    Activity? activity;
    if (activityJson != null) {
      activity = Activity.fromJson(activityJson);
    }

    // Parse timestamp from timestampString
    DateTime? timestamp;
    if (timestampString != null) {
      timestamp = DateTime.parse(timestampString);
    }

    // Create and return a GeofenceRadius object
    return GeofenceRadius(
      id: id,
      data: data,
      length: length,
    )
      .._status = status
      .._activity = activity
      .._speed = speed
      .._timestamp = timestamp
      .._remainingDistance = remainingDistance;
  }

  /// Update the remaining distance of [GeofenceRadius].
  void updateRemainingDistance(double distance) {
    if (distance < 0.0) _remainingDistance = 0.0;
    _remainingDistance = distance;
  }

  /// Update the status of [GeofenceRadius].
  /// Returns true if the status changes, false otherwise.
  bool updateStatus(GeofenceStatus status, Activity activity, double? speed,
      DateTime? timestamp) {
    if (status != _status) {
      _status = status;
      _activity = activity;
      _speed = speed;
      _timestamp = timestamp;
      return true;
    }

    return false;
  }
}
