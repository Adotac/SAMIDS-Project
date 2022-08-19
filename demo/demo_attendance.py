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
from pathlib import Path
from time import time
import time

import web_api
api = web_api.API()
CamScaleW = 1072
CamScaleH = 762

OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets/attendance")
def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)

class AttendanceApp:

    def __init__(self, window, window_title, video_source=0):

        self.window = window
        self.window.title(window_title)
        self.window.geometry(str(CamScaleW) + "x" + str(CamScaleH))
        self.window.configure(bg = "#3E4541")
        self.window.resizable(width=False, height=True)
        self.video_source = video_source
        self.ok = False

        self.selectedCode = "11003"

        self.canvas = tk.Canvas(
            window,
            bg="#3E4541",
            height=CamScaleH,
            width=CamScaleW,
            bd=0,
            highlightthickness=0,
            relief="ridge"
        )

        self.canvas.place(x=0, y=0)
        self.canvas.create_rectangle(
            0.0,
            0.0,
            1072.0,
            51.0,
            fill="#E9A91C",
            outline="")

        self.canvas.create_text(
            36.0,
            13.0,
            anchor="nw",
            text="SAMIDS",
            fill="#FFFFFF",
            font=("Inter Bold", 20 * -1)
        )


        # open video source (by default this will try to open the computer webcam)
        self.vid = VideoCapture(self.video_source).start()
        time.sleep(1.0)

        image_image_1 = tk.PhotoImage(
            file=relative_to_assets("image_1.png"))
        image_1 = self.canvas.create_image(
            335.0,
            513.0,
            image=image_image_1
        )

        self.timeDate = self.canvas.create_text(
            326.0,
            483.0,
            anchor="nw",
            text=strftime('%I:%M:%S %p\n%A, %x'),
            fill="#130000",
            font=("Inter Bold", 16 * -1)
        )


        self.canvas.create_text(
            88.0,
            494.0,
            anchor="nw",
            text="5:12:01\nBLD_A",
            fill="#000000",
            font=("Inter Bold", 16 * -1)
        )

        image_image_3 = tk.PhotoImage(
            file=relative_to_assets("image_3.png"))
        image_3 = self.canvas.create_image(
            848.0,
            407.0,
            image=image_image_3
        )

        self.att_log = self.canvas.create_text(
            958.0,
            157.0,
            anchor="ne",
            text=api.printLog(),
            fill="#000000",
            font=("Inter Bold", 16 * -1),
            width=348
        )
        # self.att_log = tk.Entry(
        #     bd=0,
        #     bg="#FFFFFF",
        #     highlightthickness=0,
        #     font=("Inter Bold", 16 * -1)
        # )
        # self.att_log.place(
        #     x=848.0,
        #     y=407.0,
        #     width=188.0,
        #     height=60.0
        # )


        button_image_1 = tk.PhotoImage(
            file=relative_to_assets("button_1.png"))
        button_1 = tk.Button(
            image=button_image_1,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: print("button_1 clicked"),
            relief="flat"
        )
        button_1.place(
            x=48.0,
            y=582.0,
            width=278.0,
            height=61.0
        )

        button_image_2 = tk.PhotoImage(
            file=relative_to_assets("button_2.png"))
        button_2 = tk.Button(
            image=button_image_2,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: print("button_2 clicked"),
            relief="flat"
        )
        button_2.place(
            x=48.0,
            y=659.0,
            width=278.0,
            height=61.0
        )

        button_image_3 = tk.PhotoImage(
            file=relative_to_assets("button_3.png"))
        button_3 = tk.Button(
            image=button_image_3,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: print("button_3 clicked"),
            relief="flat"
        )
        button_3.place(
            x=336.0,
            y=659.0,
            width=287.0,
            height=61.0
        )

        button_image_4 = tk.PhotoImage(
            file=relative_to_assets("button_4.png"))
        button_4 = tk.Button(
            image=button_image_4,
            borderwidth=0,
            highlightthickness=0,
            command=self.transition,
            relief="flat"
        )
        button_4.place(
            x=785.0,
            y=5.0,
            width=247.0,
            height=39.0
        )

        button_image_5 = tk.PhotoImage(
            file=relative_to_assets("button_5.png"))
        button_5 = tk.Button(
            image=button_image_5,
            borderwidth=0,
            highlightthickness=0,
            command=self.CheckAttendance,
            relief="flat"
        )
        button_5.place(
            x=564.0,
            y=581.0,
            width=59.0,
            height=62.0
        )

        entry_image_1 = tk.PhotoImage(
            file=relative_to_assets("entry_1.png"))
        entry_bg_1 = self.canvas.create_image(
            450.0,
            612.0,
            image=entry_image_1
        )
        self.eID = tk.Entry(
            bd=0,
            bg="#FFFFFF",
            highlightthickness=0
        )
        self.eID.place(
            x=356.0,
            y=581.0,
            width=188.0,
            height=60.0
        )
        # self.timeDate = tk.Label(window, font=('Montserrat', 18, 'bold'), bg='#c4c4c4')
        # self.timeDate.grid(row=1, column=0, columnspan=2, sticky='ew', ipady=15)
        # self.TimeDate()

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
        # self.attend = tk.Button(window, text="Log Attendance", state='disabled', fg='white', bg='#0034D1')
        # self.attend.grid(row=6, column=0, sticky='e', ipadx=75, ipady=5, pady=10, padx=5)
        #
        # # quit button
        # self.btn_quit = tk.Button(window, text='Exit', fg='white', bg='#0034D1', command=quit)
        # self.btn_quit.grid(row=6, column=1, sticky='w', ipadx=25, ipady=5, pady=10, padx=5)

        # After it is called once, the update method will be automatically called every delay milliseconds
        self.delay = 10
        self.update()
        print("False")
        window.mainloop()

        print("End")

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
            img_cam = PIL.Image.fromarray(frame)
            img_cam = img_cam.resize((575, 379))
            self.photo = PIL.ImageTk.PhotoImage(image=img_cam)
            self.canvas.create_image(335.0, 283.0, image=self.photo, anchor=tk.CENTER)

        # print(self.vid.pf)
        self.TimeDate()
        self.window.after(self.delay, self.update)

        # function to be called that checks the empID input when attendance button is clicked

    def CheckAttendance(self):
        def processAttendance():
            # get id input
            inputID = self.eID.get()
            print(inputID)

            if self.vid.pf:
                if api.check_if_account_exists(inputID):
                    print("from face detection -- " + self.vid.name)
                    if api.crosscheck_face_name_to_db(inputID, self.vid.name):
                        # get the time with 12hr format HH:MM AM/PM
                        _time = time.strftime("%I:%M %p")
                        print("Time: ")
                        print(_time)
                        # get the class schedule from cbox
                        # sched_index = self.cb.current()
                        sched_index = 0

                        print("RFID exists!")
                        remark = remarks(sched_index)
                        addAttendance(remark, sched_index, inputID)
                    else:
                        messagebox.showerror("ERROR!", "RFID and Face entry doesn't match!")
                else:
                    messagebox.showerror("ERROR!", "Invalid RFID")
                    print("Cannot recognize RFID input")
            else:
                messagebox.showerror("Anti-Spoofing ERROR!", "Spoofing detected!")
            return

        def remarks(index):
            # get the index of sch_time in class_schedule

            # split the sch_time by spaces
            sch_time = ["03:30 pm", "04:30 pm"]

            start = sch_time[0]
            print(start)
            end = sch_time[1]
            print(end)

            # convert the start and end time to 24hr format
            start = time.strptime(start, "%I:%M %p")
            start = time.strftime("%H:%M", start)
            print(start)

            end = time.strptime(end, "%I:%M %p")
            end = time.strftime("%H:%M", end)
            print(end)

            _time = time.strftime("%H:%M")
            # print(_time)

            # split the start and end time by :
            startS = start.split(':')
            # print(startS)

            endS = end.split(':')
            # print(endS)

            # split the time by :
            timeX = _time.split(':')
            # print(timeX)

            # convert the start and end time to int
            startInts = [int(i) for i in startS]
            print(startInts)

            endInts = [int(i) for i in endS]
            print(endInts)

            # convert the time to int
            timeS = [int(i) for i in timeX]
            print(timeS)

            add = startInts[1] + 15  # 15 minutes late
            print(add)

            if (timeS[0] > startInts[0]) and (timeS[1] >= endInts[1]):
                remark = "Absent"
                print(remark)
                return remark
            if timeS[0] < startInts[0]:
                remark = "Early"
                print(remark)
                return remark
            if timeS[0] == startInts[0]:
                if (timeS[1] >= startInts[1]) and (timeS[1] <= add):
                    remark = "Present"
                    print(remark)
                    return remark
                elif timeS[1] >= add:
                    remark = "Late"
                    print(remark)
                    return remark
            else:
                remark = "Absent"
                print(remark)
                return remark

        def addAttendance(remark, index, id):
            data = {
                'remarks': remark,
                'classcode': self.selectedCode,
                'date': strftime('%d/%m/%Y'),
                'time': strftime('%I:%M %p'),
                'uid': int(id)
            }
            print(data)
            response = api.add_attendance(body=data)
            self.LogAttendance()
            print(response.json())
            # try:
            #     if response['success']:
            #         print("adding attendance success!!")
            # except:
            #     print("adding attendance failed")
            #     print("API Error!")

        proc_thread = threading.Thread(target=processAttendance)
        proc_thread.start()

    def TimeDate(self):
        time_string = strftime('%I:%M:%S %p\n%A, %x')  # time format
        self.canvas.itemconfig(self.timeDate, text=time_string)
        # self.timeDate.after(1000, self.TimeDate)  # time delay of 1000 milliseconds
    def LogAttendance(self):
        log_string = api.printLog()  # time format
        self.canvas.itemconfig(self.att_log, text=log_string)

    def transition(self):
        self.window.destroy()
        print("True")
        self.window = None
        self.Tflag1 = True
        self.Tflag2 = False
        # IntrusionApp(tk.Tk(), 'Intrusion System')


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

        path = r"haarcascade_frontalface_alt_tree.xml"
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
            roi_gray = gray_frame[y:y+h, x:x+w] #cropping the face
            HSV_frame = HSV_cv[y:y + h, x:x + w]
            YCbCr_frame = YCbCr_cv[y:y + h, x:x + w]

            id_1, conf1 = recognizer.predict(roi_gray)
            id_2, conf2 = recognizer.predict(HSV_frame)
            id_3, conf3 = recognizer.predict(YCbCr_frame)

            if conf1 >= 45 and conf1 <= 80:
                # print("HSV!!")
                if (y < 100 or w < 210) or (x >= 230 or w >= 259):
                    self.name = "Position head properly"
                    color = (128, 0, 128)
                    cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                    cv2.rectangle(frame, point, (x + w, y + h), color, stroke)
                    self.pf = False
                else:
                    self.name = labels[id_2]
                    color = (255, 255, 255)
                    cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                    self.pf = True

                # color = (255, 255, 255)
                # cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                continue
            if conf2 >= 45 and conf2 <= 80:
                # print("HSV!!")
                if (y < 100 or w < 210) or (x >= 230 or w >= 259):
                    self.name = "Position head properly"
                    color = (128, 0, 128)
                    cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                    cv2.rectangle(frame, point, (x + w, y + h), color, stroke)
                    self.pf = False
                else:
                    self.name = labels[id_2]
                    color = (255, 255, 255)
                    cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                    self.pf = True

                # color = (255, 255, 255)
                # cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                continue
            if conf3 >= 45 and conf3 <= 80:
                # print("YCbCr!!")
                self.name = labels[id_3]
                color = (0, 255, 0)
                cv2.putText(frame, self.name, point, font, fScale, color, stroke, cv2.LINE_AA)
                cv2.rectangle(frame, point, (x + w, y + h), color, stroke)
                self.pf = True
                # continue
            else:
                name = "False"
                color = (0, 0, 255)
                cv2.putText(frame, name, point, font, fScale, color, stroke, cv2.LINE_AA)
                cv2.rectangle(frame, point, (x + w, y + h), color, stroke)
                self.pf = False
            # drawing rectangle around the face

    # Release the video source when the object is destroyed
    def __del__(self):
        if self.vid.isOpened():
            self.vid.release()
            cv2.destroyAllWindows()


