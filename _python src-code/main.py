import tkinter as tk
from tkinter import filedialog, ttk, Toplevel
import tkinter.messagebox as messagebox

import threading
import subprocess
import sys
import time

import cv2

import ConvertVideoToFrame as CVF
from facenet_svm import FaceRecognition
from ImagePredictor import ImagePredictor

server_process = None


def main():
    def browse_directory(entry):
        dirname = filedialog.askdirectory()
        entry.delete(0, tk.END)
        entry.insert(0, dirname)

    def train_model():
        FaceRecognition().train()

    def check_face():
        open_check_face_dialog()

    def start_process_videos(n: int, on_closing):
        face_cropper = CVF.FrameExtractor(nframes=n)
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

        # Validation function for the integer Entry widget
        def validate_integer_input(value_if_allowed):
            if value_if_allowed == "":
                return True
            if value_if_allowed.isdigit():
                return True
            return False

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

        process_videos_button = tk.Button(crop_videos_dialog, text="Crop Videos",
                                          command=lambda: start_process_videos(int(int_var.get()), on_closing))
        process_videos_button.grid(row=2, column=1, padx=5, pady=5)

        # Add a new label and Entry for the integer input
        int_label = tk.Label(crop_videos_dialog, text="Integer Input:")
        int_label.grid(row=4, column=0, sticky="e", padx=5, pady=5)
        int_var = tk.StringVar()
        int_var.set("100")  # Set the default value to 200
        int_entry_validation = crop_videos_dialog.register(validate_integer_input)
        int_entry = tk.Entry(crop_videos_dialog, width=40, textvariable=int_var, validate="key",
                             validatecommand=(int_entry_validation, '%P'))
        int_entry.grid(row=3, column=1, padx=5, pady=5)

        global progress_bar
        progress_label = tk.Label(crop_videos_dialog, text="Progress:")
        progress_label.grid(row=3, column=0, sticky="e")
        progress_bar = ttk.Progressbar(crop_videos_dialog, orient="horizontal", length=200, mode="determinate")
        progress_bar.grid(row=4, column=1)

        crop_videos_dialog.protocol("WM_DELETE_WINDOW", on_closing)

    def open_check_face_dialog():
        check_face_dialog = Toplevel(root)
        check_face_dialog.title("Check Face")

        predictor = ImagePredictor()

        def checkImage():
            filetypes = [("Image files", "*.jpg;*.jpeg;*.png;*.bmp;*.tiff;*.gif")]
            image_path = filedialog.askopenfilename(title="Select an Image", filetypes=filetypes)

            if image_path:
                frame = cv2.imread(image_path)
                if frame is not None:
                    label_name = predictor.predict_label(frame)
                    messagebox.showinfo("Prediction", f"The predicted label of the image is: {label_name}")
                else:
                    messagebox.showerror("Error", "Error reading the image. Please select a valid image file.")

        def checkStream():
            ip_input = ip_entry.get()
            if ip_input != "":
                # Create a new thread for the predictor.predict_display function
                thread = threading.Thread(target=predictor.predict_display, args=(ip_input,))
                # Start the thread
                thread.start()

        def on_closing():
            check_face_dialog.destroy()

        ip_label = tk.Label(check_face_dialog, text="IP Address:")
        ip_label.grid(row=0, column=0, sticky="e", padx=5, pady=5)
        ip_entry = tk.Entry(check_face_dialog, width=40)
        ip_entry.grid(row=0, column=1, padx=5, pady=5)
        ip_entry.insert(0, "192.168.43.245")

        model_path_label = tk.Label(check_face_dialog, text="Model Path:")
        model_path_label.grid(row=1, column=0, sticky="e", padx=5, pady=5)
        model_path_entry = tk.Entry(check_face_dialog, width=40)
        model_path_entry.grid(row=1, column=1, padx=5, pady=5)
        model_path_button = tk.Button(check_face_dialog, text="Browse",
                                      command=lambda: browse_directory(model_path_entry))
        model_path_button.grid(row=1, column=2, padx=5, pady=5)

        facenet_path_label = tk.Label(check_face_dialog, text="FaceNet Pretrained Model:")
        facenet_path_label.grid(row=2, column=0, sticky="e", padx=5, pady=5)
        facenet_path_entry = tk.Entry(check_face_dialog, width=40)
        facenet_path_entry.grid(row=2, column=1, padx=5, pady=5)
        facenet_path_button = tk.Button(check_face_dialog, text="Browse",
                                        command=lambda: browse_directory(facenet_path_entry))
        facenet_path_button.grid(row=2, column=2, padx=5, pady=5)

        upload_image_button = tk.Button(check_face_dialog, text="Upload Image",
                                        command=checkImage)  # Replace with your upload_image function
        upload_image_button.grid(row=3, column=1, padx=5, pady=5)

        stream_ip_camera_button = tk.Button(check_face_dialog, text="Stream IP Camera",
                                            command=checkStream)  # Replace with your stream_ip_camera function
        stream_ip_camera_button.grid(row=3, column=2, padx=5, pady=5)

        check_face_dialog.protocol("WM_DELETE_WINDOW", on_closing)

    root = tk.Tk()
    root.title("AI-API Server")
    root.geometry("250x70")

    train_button = tk.Button(root, text="Train Model", command=train_model)
    train_button.grid(row=0, column=0, padx=25, pady=5)

    server_button = tk.Button(root, text="Start Server", command=start_server)
    server_button.grid(row=0, column=1, padx=25, pady=5)

    crop_videos_button = tk.Button(root, text="Crop Videos", command=open_crop_videos_dialog)
    crop_videos_button.grid(row=2, column=0, padx=25, pady=5)

    check_button = tk.Button(root, text="Check Face", command=check_face)
    check_button.grid(row=2, column=1, padx=25, pady=5)

    root.mainloop()


if __name__ == '__main__':
    thread = threading.Thread(target=main)
    thread.start()
