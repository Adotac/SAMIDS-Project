import tkinter as tk
from tkinter import filedialog, ttk
import threading
import os
import subprocess
import sys

import ConvertFromVideotoDataset as CFVD

server_process = None

face_cropper = CFVD.FrameExtractor("dummy", "dummy")

def browse_directory(entry):
    dirname = filedialog.askdirectory()
    entry.delete(0, tk.END)
    entry.insert(0, dirname)

def train_model():

    pass

def check_face():
    pass

def start_process_videos():
    global face_cropper

    def update_progress(value):
        progress_bar['value'] = value
        root.update_idletasks()

    def run_process_videos():
        face_cropper = CFVD.FrameExtractor(vidpath, oupath, progress_callback=update_progress)
        result = face_cropper.process_videos()
        print(result)

    vidpath = dir1_entry.get()
    oupath = dir2_entry.get()

    face_cropper.update_paths(vidpath, oupath)

    threading.Thread(target=run_process_videos).start()


def start_server():
    def run_fastapi():
        global server_process
        server_process = subprocess.Popen([sys.executable, "-m", "main_server"], shell=False)

    threading.Thread(target=run_fastapi).start()
    # root.destroy()

root = tk.Tk()
root.title("AI-API Server")

dir1_label = tk.Label(root, text="Video Path:")
dir1_label.grid(row=0, column=0, sticky="e")
dir1_entry = tk.Entry(root, width=40)
dir1_entry.grid(row=0, column=1)
dir1_button = tk.Button(root, text="Browse", command=lambda: browse_directory(dir1_entry))
dir1_button.grid(row=0, column=2)

dir2_label = tk.Label(root, text="Output Path:")
dir2_label.grid(row=1, column=0, sticky="e")
dir2_entry = tk.Entry(root, width=40)
dir2_entry.grid(row=1, column=1)
dir2_button = tk.Button(root, text="Browse", command=lambda: browse_directory(dir2_entry))
dir2_button.grid(row=1, column=2)

model_label = tk.Label(root, text="Model File:")
model_label.grid(row=2, column=0, sticky="e")
model_entry = tk.Entry(root, width=40)
model_entry.grid(row=2, column=1)
model_button = tk.Button(root, text="Browse", command=lambda: browse_directory(model_entry))
model_button.grid(row=2, column=2)

train_button = tk.Button(root, text="Train Model", command=train_model)
train_button.grid(row=3, column=0, pady=10)
check_button = tk.Button(root, text="Check Face", command=check_face)
check_button.grid(row=3, column=2, pady=10)
server_button = tk.Button(root, text="Start Server", command=start_server)
server_button.grid(row=3, column=1, pady=10)

progress_label = tk.Label(root, text="Progress:")
progress_label.grid(row=5, column=0, sticky="e")
progress_bar = ttk.Progressbar(root, orient="horizontal", length=200, mode="determinate")
progress_bar.grid(row=5, column=1)

process_videos_button = tk.Button(root, text="Process Videos", command=start_process_videos)
process_videos_button.grid(row=6, column=1, pady=10)

root.mainloop()
