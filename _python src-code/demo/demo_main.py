import tkinter as tk
from demo_attendance import AttendanceApp
from demo_intrusion import IntrusionApp

def main():
    # Create a window and pass it to the Application object
    w = AttendanceApp(tk.Tk(), 'Attendance System')
    while True:
        if w.Tflag1:
            w = IntrusionApp(tk.Tk(), 'Intrusion System')
            continue

        if w.Tflag2:
            w = AttendanceApp(tk.Tk(), 'Attendance System')
            continue


if __name__ == "__main__":
    main()