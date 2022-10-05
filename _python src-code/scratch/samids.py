import tkinter as tk
from tkinter.ttk import Combobox
from tkinter import messagebox

import PIL.Image, PIL.ImageTk
from time import strftime

from time import time
import time

import threading
import cv2
import numpy as np


CamScaleW = 900
CamScaleH = 500

class App:

    def __init__(self, window, window_title, video_source=0, w_win=1440, h_win=900):
        self.window = window
        self.window.title(window_title)
        self.window.geometry(str(w_win) + "x" + str(h_win))
        self.window.resizable(width=False, height=True)
        self.video_source = video_source
        self.ok = False

        # open video source (by default this will try to open the computer webcam)
        self.vid = VideoCapture(self.video_source, wsize=CamScaleW, hsize=CamScaleH).start()
        time.sleep(1.0)
        # Create a canvas that can fit the above video source size
        self.canvas = tk.Canvas(window, width=CamScaleW, height=CamScaleH)
        self.canvas.grid(row=0, column=0, columnspan=2)



        # quit button
        self.btn_quit = tk.Button(window, text='Exit', fg='white', bg='#0034D1', command=quit)
        self.btn_quit.grid(row=6, column=1, sticky='w', ipadx=25, ipady=5, pady=10, padx=5)

        # After it is called once, the update method will be automatically called every delay milliseconds
        self.delay = 10
        self.update()
        window.mainloop()

    def update(self):
        start_time = time.time()

        # Get a frame from the video source
        ret, frame = self.vid.get_frame()

        end_time = time.time()
        fps = 1 / np.round(end_time - start_time, 2)
        # print(f"Frames Per Second : {fps}")
        formatFps = "{:.2f}".format(fps)
        cv2.putText(frame, f'FPS: ' + formatFps, (20, 70), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)

        if ret:
            self.photo = PIL.ImageTk.PhotoImage(image=PIL.Image.fromarray(frame))
            self.canvas.create_image(0, 0, image=self.photo, anchor=tk.NW)

        # print(self.vid.pf)

        self.window.after(self.delay, self.update)

class VideoCapture:
    def __init__(self, video_source=0, wsize=620, hsize=480,  qSize=128):
        # Open the video source
        self.hs = hsize
        self.ws = wsize
        self.source = video_source
        self.vid = cv2.VideoCapture(video_source)
        if not self.vid.isOpened():
            raise ValueError("Unable to open video source", video_source)

    def start(self):
        t = threading.Thread(target=self.get_frame, args=())
        t.daemon = True
        t.start()
        return self

    # To get frames
    def get_frame(self):
        if self.vid.isOpened():

            ret, fr = self.vid.read()
            fr = cv2.resize(fr, (self.ws, self.hs), fx=0, fy=0, interpolation=cv2.INTER_CUBIC)
            assert ret
            if ret:
                return (ret, cv2.cvtColor(fr, cv2.COLOR_RGB2BGR))
            else:
                return (ret, None)
        else:
            return (None, None)

    # Release the video source when the object is destroyed
    def __del__(self):
        if self.vid.isOpened():
            self.vid.release()
            cv2.destroyAllWindows()

def main():
    # Create a window and pass it to the Application object
    App(tk.Tk(), 'Attendance System')


if __name__ == "__main__":
    main()