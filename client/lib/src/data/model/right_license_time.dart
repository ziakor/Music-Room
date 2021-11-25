import 'dart:convert';

class RightLicenseTime {
  final int start;
  final int end;

  const RightLicenseTime({this.start = 0, this.end = 0});

  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
    };
  }

  factory RightLicenseTime.fromMap(Map<String, dynamic> map) {
    return RightLicenseTime(
      start: map['start'],
      end: map['end'],
    );
  }
}
