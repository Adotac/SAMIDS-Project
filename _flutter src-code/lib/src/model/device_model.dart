class Device {
  int deviceId;
  String room;

  Device({
    required this.deviceId,
    required this.room,
  });

  static Device fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'],
      room: json['room'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['room'] = room;
    return data;
  }
}
