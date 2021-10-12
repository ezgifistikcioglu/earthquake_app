class Earthquake {
  double? mag;
  double? lng;
  double? lat;
  String? location;
  double? depth;
  List<double>? coordinates;
  String? title;
  dynamic rev;
  int? timestamp;
  DateTime? dateStamp;
  String? date;
  String? hash;
  String? hash2;

  Earthquake({
    this.mag,
    this.lng,
    this.lat,
    this.location,
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


  factory Earthquake.fromMap(Map<String, dynamic> map) => Earthquake(
    mag: map['mag'] == null ? null : map["mag"].toDouble(),
    lng: map['lng'] == null ? null : map["lng"].toDouble(),
    lat: map['lat'] == null ? null : map["lat"].toDouble(),
    location: map['location'] == null ? null :map["location"],
    depth: map['depth'] == null ? null : map["depth"].toDouble(),
    coordinates: map['coordinates'] == null ? null :
    List<double>.from(map["coordinates"].map((x) => x.toDouble())),
    title: map['title'] == null ? null : map["title"],
    rev: map['rev'] == null ? null : map["rev"],
    timestamp: map['timestamp'] == null ? null : map["timestamp"],
    dateStamp: map['date_stamp'] == null ? null : DateTime.parse(map["date_stamp"]),
    date: map['date'] == null ? null : map["date"],
    hash: map['hash'] == null ? null : map["hash"],
    hash2: map['hash2'] == null ? null : map["hash2"],
  );

  Map<String, dynamic> toJson() => {
    "mag": mag,
    "lng": lng,
    "lat": lat,
    "location": location,
    "depth": depth,
    "coordinates": List<dynamic>.from(coordinates!.map((x) => x)),
    "title": title,
    "rev": rev,
    "timestamp": timestamp,
    "date_stamp":
    "${dateStamp!.year.toString().padLeft(4, '0')}-${dateStamp!.month.toString().padLeft(2, '0')}-${dateStamp!.day.toString().padLeft(2, '0')}",
    "date": date,
    "hash": hash,
    "hash2": hash2,
  };
}