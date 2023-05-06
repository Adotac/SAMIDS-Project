import csv
import logging
import sys
import os
from datetime import datetime

class CsvFormatter(logging.Formatter):
    def __init__(self, fieldnames):
        super().__init__()
        self.fieldnames = fieldnames

    def format(self, record):
        row = {fieldname: '' for fieldname in self.fieldnames}
        row['timestamp'] = datetime.fromtimestamp(record.created).strftime('%Y-%m-%d %H:%M:%S')
        row['level'] = record.levelname
        row['message'] = record.getMessage()

        for fieldname in self.fieldnames:
            if hasattr(record, fieldname):
                row[fieldname] = getattr(record, fieldname)

        return row

class CsvHandler(logging.Handler):
    def __init__(self, filepath, fieldnames):
        super().__init__()
        self.filepath = filepath
        self.fieldnames = fieldnames

        # Create the log file with fieldnames if it doesn't exist
        if not os.path.exists(filepath):
            with open(filepath, 'w', newline='') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()

    def emit(self, record):
        log_entry = self.format(record)

        with open(self.filepath, 'a', newline='') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=self.fieldnames)
            writer.writerow(log_entry)

fieldnames = ['timestamp', 'user_id', 'level', 'message', 'rfid', 'tap_time', 'room']
log_filepath = 'attendance_log.csv'

handler = CsvHandler(log_filepath, fieldnames)
handler.setFormatter(CsvFormatter(fieldnames))

logger = logging.getLogger('attendance_log')
logger.setLevel(logging.INFO)
logger.addHandler(handler)
