class Device {
  int deviceId;
  String room;

  Device({
    required this.deviceId,
    required this.room,
  });

  static Device fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['DeviceId'],
      room: json['Room'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DeviceId'] = deviceId;
    data['Room'] = room;
    return data;
  }
}