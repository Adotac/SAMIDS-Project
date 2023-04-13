class EnumValues<T> {
  late Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map) {
    reverseMap = map.map((k, v) => MapEntry(v, k));
  }

  Map<T, String> get reverse {
    return reverseMap;
  }
}

//Remarks Helper
enum Remarks
    {
        OnTime, // 0
        Late, // 1
        Cutting, // 2
        Absent // 3

    }

//Year Helper
Year yearFromJson(String year) {
  switch (year) {
    case 'First':
      return Year.First;
    case 'Second':
      return Year.Second;
    case 'Third':
      return Year.Third;
    case 'Fourth':
      return Year.Fourth;
    default:
      throw ArgumentError('Invalid year: $year');
  }
}

String yearToJson(Year year) {
  switch (year) {
    case Year.First:
      return 'First';
    case Year.Second:
      return 'Second';
    case Year.Third:
      return 'Third';
    case Year.Fourth:
      return 'Fourth';
    default:
      throw ArgumentError('Invalid year: $year');
  }
}

enum Year {
  First,
  Second,
  Third,
  Fourth,
}

//Date Helper
DateTime toDateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

//Type Helper
Types typeFromJson(String type) {
  switch (type) {
    case 'Admin':
      return Types.Admin;
    case 'Faculty':
      return Types.Faculty;
    case 'Student':
      return Types.Student;
    default:
      throw ArgumentError('Invalid type: $type');
  }
}

String typeToJson(Types type) {
  switch (type) {
    case Types.Admin:
      return 'Admin';
    case Types.Faculty:
      return 'Faculty';
    case Types.Student:
      return 'Student';
    default:
      throw ArgumentError('Invalid type: $type');
  }
}

enum Types {
  Admin,
  Faculty,
  Student,
}
