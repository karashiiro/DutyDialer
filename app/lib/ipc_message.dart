class IpcMessage {
  final String
      type; // This should be an enum, but I can't reflect to one cleanly
  final int unixMilliseconds;
  final String contentName;
  final String banner;

  IpcMessage({
    required this.type,
    required this.unixMilliseconds,
    required this.contentName,
    required this.banner,
  });

  factory IpcMessage.fromJson(Map<String, dynamic> json) {
    return IpcMessage(
      type: json["type"] as String,
      unixMilliseconds: int.tryParse(json["unix_milliseconds"] as String) ?? 0,
      contentName: json["content_name"] as String,
      banner: json["banner"] as String,
    );
  }
}
