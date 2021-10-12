import 'dart:convert';

import 'earthquake.dart';

class EarthquakeResponseData {
  bool? status;
  List<Earthquake?>? result;

  EarthquakeResponseData({
    this.status,
    this.result,
  });

  factory EarthquakeResponseData.fromMap(Map<String, dynamic> map) =>
      EarthquakeResponseData(
        status: map['status'] == null ? null : map["status"],
        result: map['result'] == null
            ? null
            : List<Earthquake>.from(
                map["result"].map((x) => Earthquake.fromMap(x))),
      );

  Map<String, dynamic> toMap() {
    return {
      "status": status,
      "result": List<dynamic>.from(result!.map((x) => x!.toJson())),
    };
  }

  String toJson() => json.encode(toMap());

  factory EarthquakeResponseData.fromJson(String source) =>
      EarthquakeResponseData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'EarthquakeResponseData(status: $status, result: $result)';
  }
}
