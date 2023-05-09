import pandas as pd
import matplotlib.pyplot as plt
from io import StringIO

datapath = './attendance_log.csv'

# Read the data into a pandas DataFrame
df = pd.read_csv(datapath, parse_dates=['timestamp', 'tap_time'])


# Initialize a set to store unique RFIDs for non-OnTime messages
unique_rfids = set()

# Iterate through the rows of the data
for index, row in df.iterrows():
    rfid = row['rfid']
    message = row['message']

    # Check if the message is "Attendance OnTime"
    if message != 'Attendance OnTime':
        # Add the RFID to the set
        unique_rfids.add(rfid)

# Print the count of unique RFIDs for non-OnTime messages
print(len(unique_rfids))