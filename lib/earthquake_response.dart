import 'dart:convert';

EartquakeResponseData eartquakeResponseDataFromJson(String str) => EartquakeResponseData.fromJson(json.decode(str));

String eartquakeResponseDataToJson(EartquakeResponseData data) => json.encode(data.toJson());

class EartquakeResponseData {
    EartquakeResponseData({
        this.status,
        this.result,
    });

    bool status;
    List<Earthquake> result;

    factory EartquakeResponseData.fromJson(Map<String, dynamic> json) => EartquakeResponseData(
        status: json["status"],
        result: List<Earthquake>.from(json["result"].map((x) => Earthquake.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
    };
}

class Earthquake {
    Earthquake({
        this.mag,
        this.lng,
        this.lat,
        this.lokasyon,
        this.depth,
        this.coordinates,
        this.title,
        this.rev,
        this.timestamp,
        this.dateStamp,
        this.date,
        this.hash,
        this.hash2,
    });

    double mag;
    double lng;
    double lat;
    String lokasyon;
    double depth;
    List<double> coordinates;
    String title;
    dynamic rev;
    int timestamp;
    DateTime dateStamp;
    String date;
    String hash;
    String hash2;

    factory Earthquake.fromJson(Map<String, dynamic> json) => Earthquake(
        mag: json["mag"].toDouble(),
        lng: json["lng"].toDouble(),
        lat: json["lat"].toDouble(),
        lokasyon: json["lokasyon"],
        depth: json["depth"].toDouble(),
        coordinates: List<double>.from(json["coordinates"].map((x) => x.toDouble())),
        title: json["title"],
        rev: json["rev"],
        timestamp: json["timestamp"],
        dateStamp: DateTime.parse(json["date_stamp"]),
        date: json["date"],
        hash: json["hash"],
        hash2: json["hash2"],
    );

    Map<String, dynamic> toJson() => {
        "mag": mag,
        "lng": lng,
        "lat": lat,
        "lokasyon": lokasyon,
        "depth": depth,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
        "title": title,
        "rev": rev,
        "timestamp": timestamp,
        "date_stamp": "${dateStamp.year.toString().padLeft(4, '0')}-${dateStamp.month.toString().padLeft(2, '0')}-${dateStamp.day.toString().padLeft(2, '0')}",
        "date": date,
        "hash": hash,
        "hash2": hash2,
    };
}