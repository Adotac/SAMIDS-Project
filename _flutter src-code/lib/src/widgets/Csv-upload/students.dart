import 'dart:convert';
import 'package:csv/csv.dart';

class CSVFileUpload {
  static Future<void> uploadCsv(List<int> fileBytes, int table) async {
    try {
      final csvFile = utf8.decode(fileBytes);
      switch (table) {
        case 0:
          break;
        case 1:
          break;
        case 2:
          break;
        case 3:
          break;
        case 4:
          break;
        default:
      }
      return;
    } catch (e) {
      print('Error checking CSV file: $e');
      return;
    }
  }
}
