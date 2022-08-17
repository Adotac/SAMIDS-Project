import tkinter as tk
from tkinter.ttk import Combobox
from tkinter import messagebox
from time import strftime
import cv2
import PIL.Image, PIL.ImageTk
import pickle
import csv
import numpy as np
import threading

from time import time
import time

CamScaleW = 645
CamScaleH = 810

class App:

    def __init__(self, window, window_title, video_source=0):
        def updateLbl(*_):
            if self.eID.get():  # empty string is false
                self.attend["state"] = "normal"
            else:
                self.attend["state"] = "disable"

        self.window = window
        self.window.title(window_title)
        self.window.geometry(str(CamScaleW) + "x" + str(CamScaleH))
        self.window.resizable(width=False, height=True)
        self.video_source = video_source
        self.ok = False

        # open video source (by default this will try to open the computer webcam)
        self.vid = VideoCapture(self.video_source).start()
        time.sleep(1.0)
        # Create a canvas that can fit the above video source size
        self.canvas = tk.Canvas(window, width=640, height=480)
        self.canvas.grid(row=0, column=0, columnspan=2)

        self.timeDate = tk.Label(window, font=('Montserrat', 18, 'bold'), bg='#c4c4c4')
        self.timeDate.grid(row=1, column=0, columnspan=2, sticky='ew', ipady=15)
        self.TimeDate()

        # # A combo box to choose what class you're trying to check attendance to
        # self.id_label = tk.Label(window, text='Class Schedule', font=('Montserrat', 12, 'bold'))
        # self.id_label.grid(row=2, column=0, columnspan=2, sticky='S')
        # self.cBoxData = self.ClassSched()
        # self.cb = Combobox(window, values=self.cBoxData, state='readonly')
        # self.cb.grid(row=3, column=0, columnspan=2, ipadx=100, ipady=5, pady=15)

        # # employee ID input
        # self.id_label = tk.Label(window, text='Faculty ID', font=('Montserrat', 12, 'bold'))
        # self.id_label.grid(row=4, column=0, columnspan=2, sticky='S')
        # self.eID = tk.Entry(window, bd=2)
        # self.eID.var  = tk.StringVar()
        # self.eID['textvariable'] = self.eID.var
        # self.eID.var.trace_add('write', updateLbl)
        # self.eID.grid(row=5, column=0, columnspan=2, ipadx=110, ipady=5, )

        # Button that lets the user take a snapshot
        self.attend = tk.Button(window, text="Log Attendance", state='disabled', fg='white', bg='#0034D1')
        self.attend.grid(row=6, column=0, sticky='e', ipadx=75, ipady=5, pady=10, padx=5)

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

    def TimeDate(self):
        time_string = strftime('%I:%M:%S %p\n%A, %x')  # time format
        self.timeDate.config(text=time_string)
        self.timeDate.after(1000, self.TimeDate)  # time delay of 1000 milliseconds


class VideoCapture:
    def __init__(self, video_source=0, qSize=128):
        # Open the video source
        self.source = video_source
        # self.obj_detector = Detector(videopath=self.source)
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
            assert ret
            if ret:
                # threading.Thread(target=self.edge_detection, kwargs={'frame': fr}).start()
                self.edge_detection(frame=fr)
                # self.obj_detection(frame=fr)
                # self.rectAvg_to_csv(data=csvData)  # Enable only if you want to get the average again

                # Return a boolean success flag and the current frame converted to BGR
                return (ret, cv2.cvtColor(fr, cv2.COLOR_RGB2BGR))
            else:
                return (ret, None)
        else:
            return (None, None)

    # added by Montero, Joshua & Gadianne, James & Bohol, Christopher
    # def obj_detection(self, frame):
    #     results = self.obj_detector.score_frame(frame)
    #     f, self.pf = self.obj_detector.plot_boxes(results, frame)

    # added by Bohol, Christopher
    def edge_detection(self, frame):

        path = r"dataset\cascades\haarcascade_frontalface_alt_tree.xml"
        face_cascade = cv2.CascadeClassifier(path)

        # added and edited by Gadiane, James Christian
        # modified by Montero, Joshua - Color Spaces discrimination
        recognizer = cv2.face.LBPHFaceRecognizer_create()
        recognizer.read("demo_trained.yml")
        with open("demo_labels.pkl", 'rb') as f:
            main_labels = pickle.load(f)
            labels = {v: k for k, v in main_labels.items()}

        HSV_cv = cv2.cvtColor(frame, cv2.COLOR_RGB2HSV)
        YCbCr_cv = cv2.cvtColor(frame, cv2.COLOR_RGB2YCrCb)

        gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)  # converting frame to grayscale
        HSV_cv = cv2.cvtColor(HSV_cv, cv2.COLOR_BGR2GRAY)
        YCbCr_cv = cv2.cvtColor(YCbCr_cv, cv2.COLOR_BGR2GRAY)

        faces = face_cascade.detectMultiScale(gray_frame, scaleFactor=1.1,
                                              minNeighbors=5)  # detecting faces in the frame

        font = cv2.FONT_HERSHEY_SIMPLEX
        fScale = (CamScaleW * CamScaleH) / (900 * 900)
        stroke = 2
        for (x, y, w, h) in faces:
            point = (x, y)
            print(x, y, w, h)

            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), stroke)
            # roi_gray = gray_frame[y:y+h, x:x+w] #cropping the face
            HSV_frame = HSV_cv[y:y + h, x:x + w]
            YCbCr_frame = YCbCr_cv[y:y + h, x:x + w]

            id_2, conf2 = recognizer.predict(HSV_frame)
            id_3, conf3 = recognizer.predict(YCbCr_frame)

            if conf2 >= 50 and conf2 <= 80:
                # print("HSV!!")
                if (y < 100 or w < 210) or (x >= 230 or w >= 259):
                    self.name = "Position head properly"
                    color = (128, 0, 128)
                    cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                    cv2.rectangle(frame, point, (x + w, y + h), color, stroke)
                else:
                    self.name = labels[id_2]
                    color = (255, 255, 255)
                    cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)

                # color = (255, 255, 255)
                # cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                continue
            if conf3 >= 60 and conf3 <= 80:
                # print("YCbCr!!")
                self.name = "False"
                color = (0, 0, 255)
                cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                cv2.rectangle(frame, point, (x + w, y + h), color, stroke)
                # continue
            else:
                name = "False"
                color = (0, 0, 255)
                cv2.putText(frame, name, point, font, fScale, color, stroke, cv2.LINE_AA)
                cv2.rectangle(frame, point, (x + w, y + h), color, stroke)
            # drawing rectangle around the face

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
