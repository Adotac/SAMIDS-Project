import tkinter as tk
from tkinter import filedialog, ttk, Toplevel
import tkinter.messagebox as messagebox

import threading
import os
import subprocess
import sys
import time


import ConvertVideoToFrame as CVF

server_process = None

def browse_directory(entry):
    dirname = filedialog.askdirectory()
    entry.delete(0, tk.END)
    entry.insert(0, dirname)

def train_model():
    pass

def check_face():
    pass

def start_process_videos(on_closing):
    face_cropper = CVF.FrameExtractor()
    time.sleep(2)  # This will pause the execution for 2 seconds

    vidpath = dir1_entry.get()
    outpath = dir2_entry.get()

    def show_complete_message():
        messagebox.showinfo("Process Complete", "Video cropping is complete!")

    def update_progress(value):
        progress_bar['value'] = value
        crop_videos_dialog.update_idletasks()

    def run_process_videos():
        face_cropper.update_paths(video_path=vidpath, output_dir=outpath)
        face_cropper.setCallback(update_progress)
        result = face_cropper.process_videos()
        print(result)

        on_closing()
        show_complete_message()

    threading.Thread(target=run_process_videos).start()

def start_server():
    def run_fastapi():
        global server_process
        server_process = subprocess.Popen([sys.executable, "-m", "main_server"], shell=False)

    threading.Thread(target=run_fastapi).start()

def open_crop_videos_dialog():
    global crop_videos_dialog

    crop_videos_dialog = Toplevel(root)
    crop_videos_dialog.title("Crop Videos")
    global dir1_entry, dir2_entry

    def on_closing():
        crop_videos_dialog.destroy()

    dir1_label = tk.Label(crop_videos_dialog, text="Video Path:")
    dir1_label.grid(row=0, column=0, sticky="e", padx=5, pady=5)
    dir1_entry = tk.Entry(crop_videos_dialog, width=40)
    dir1_entry.grid(row=0, column=1, padx=5, pady=5)
    dir1_button = tk.Button(crop_videos_dialog, text="Browse", command=lambda: browse_directory(dir1_entry))
    dir1_button.grid(row=0, column=2, padx=5, pady=5)

    dir2_label = tk.Label(crop_videos_dialog, text="Output Path:")
    dir2_label.grid(row=1, column=0, sticky="e")
    dir2_entry = tk.Entry(crop_videos_dialog, width=40)
    dir2_entry.grid(row=1, column=1, padx=5, pady=5)
    dir2_button = tk.Button(crop_videos_dialog, text="Browse", command=lambda: browse_directory(dir2_entry))
    dir2_button.grid(row=1, column=2, padx=5, pady=5)

    process_videos_button = tk.Button(crop_videos_dialog, text="Crop Videos", command=lambda: start_process_videos(on_closing))
    process_videos_button.grid(row=2, column=1, padx=5, pady=5)

    global progress_bar
    progress_label = tk.Label(crop_videos_dialog, text="Progress:")
    progress_label.grid(row=3, column=0, sticky="e")
    progress_bar = ttk.Progressbar(crop_videos_dialog, orient="horizontal", length=200, mode="determinate")
    progress_bar.grid(row=3, column=1)

    crop_videos_dialog.protocol("WM_DELETE_WINDOW", on_closing)

root = tk.Tk()
root.title("AI-API Server")

train_button = tk.Button(root, text="Train Model", command=train_model)
train_button.grid(row=0, column=0, padx=5, pady=5)
check_button = tk.Button(root, text="Check Face", command=check_face)
check_button.grid(row=0, column=2, padx=5, pady=5)
server_button = tk.Button(root, text="Start Server", command=start_server)
server_button.grid(row=0, column=1, padx=5, pady=5)

crop_videos_button = tk.Button(root, text="Crop Videos", command=open_crop_videos_dialog)
crop_videos_button.grid(row=2, column=0, padx=5, pady=5)

crop_videos_button = tk.Button(root, text="Crop Videos", command=open_crop_videos_dialog)
crop_videos_button.grid(row=2, column=1, padx=5, pady=5)

root.mainloop()
