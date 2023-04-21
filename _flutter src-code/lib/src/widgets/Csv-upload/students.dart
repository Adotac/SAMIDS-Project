import 'dart:convert';
import 'package:csv/csv.dart';

class CSVFileUpload {
  static Future<bool> uploadCsv(List<int> fileBytes, int table) async {
    try {
      final csvFile = utf8.decode(fileBytes);

      switch (table) {
        case 0:

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

      final rows = CsvToListConverter().convert(csvFile);

      if (rows.isEmpty) {
        return false;
      }

      final headerRow = rows.first;

      if (headerRow.length != 7) {
        return false;
      }

      final expectedHeaders = [
        'StudentID',
        'StudentNo',
        'Rfid',
        'LastName',
        'FirstName',
        'Course',
        'Year'
      ];

      for (int i = 0; i < expectedHeaders.length; i++) {
        if (headerRow[i] != expectedHeaders[i]) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking CSV file: $e');
      return false;
    }
  }
}
