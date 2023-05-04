import os
import cv2
import mediapipe as mp

import json


class FrameExtractor:
    def __init__(self, nframes: int = 100, video_path: str = None, output_dir: str = None,
                 padding: int = 50, progress_callback=None):

        self.max_frames = nframes
        self.video_path = video_path
        self.output_dir = output_dir
        self.padding = padding
        self.progress_callback = progress_callback
        self.face_detection = mp.solutions.face_detection.FaceDetection()

    def setCallback(self, progress_callback):
        self.progress_callback = progress_callback

    def update_paths(self, video_path, output_dir):
        self.video_path = video_path
        self.output_dir = output_dir

    def process_videos(self) -> str:
        # Create output directory if it doesn't exist
        os.makedirs(self.output_dir, exist_ok=True)

        # Get the total number of video files
        video_files = [f for f in os.listdir(self.video_path)
                       if os.path.splitext(f)[1].lower()
                       in ['.mp4', '.avi', '.mkv', '.m4v', '.mov']]

        total_videos = len(video_files)
        # print(total_videos)
        videos_processed = 0

        # Loop through each file in the video_path directory
        for filename in video_files:

            # Check if the file is a video file (e.g. .mp4, .avi, .mov)
            base_filename, file_extension = os.path.splitext(filename)
            # if file_extension in ['.mp4', '.avi', '.mkv', '.m4v', '.mov']:

            # Construct the full file path
            filepath = os.path.join(self.video_path, filename)
            print(f'Reading file: {filepath}')
            videos_processed += 1

            # Open the video file
            cap = cv2.VideoCapture(filepath)

            if not cap.isOpened():
                print("Error opening video file")

            max_frame_size = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

            print(f"Video duration: {max_frame_size} frames")

            # Initialize the frame count
            frame_count = 0
            # Loop through frames in the video
            for i in range(max_frame_size):
                if frame_count < self.max_frames and cap.isOpened():
                    # Read the next frame from the video
                    ret, frame = cap.read()
                    height, width, _ = frame.shape
                    # If the frame was successfully read
                    if ret:
                        # Run face detection on the frame
                        results = self.face_detection.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))

                        # If faces were detected
                        if results.detections:
                            # Loop through the detected faces and draw bounding boxes around them
                            for detection in results.detections:
                                bbox = detection.location_data.relative_bounding_box

                                x, y, w, h = int(bbox.xmin * width), int(bbox.ymin * height), int(
                                    bbox.width * width), int(bbox.height * height)

                                # Add padding to the bounding box coordinates
                                x1 = max(0, x - self.padding)
                                y1 = max(0, y - self.padding)
                                x2 = min(width, x + w + self.padding)
                                y2 = min(height, y + h + self.padding)
                                # Crop the face region from the frame
                                face_image = frame[y1:y2, x1:x2]

                                # Save the face region as a separate image
                                face_filename = base_filename + str(frame_count) + "_face_" + str(x) + "_" + str(y) + ".jpg"
                                face_path = os.path.join(self.output_dir, base_filename)
                                os.makedirs(face_path, exist_ok=True)

                                output_path = os.path.join(face_path, face_filename)
                                # print(output_path)

                                cv2.imwrite(output_path, face_image, [cv2.IMWRITE_JPEG_QUALITY, 80])

                                # Increment the frame count
                                frame_count += 1
                        else:
                            print("No faces detected on this file.")
                    else:
                        print("Failed to read a frame in this file.")
                        break

            if (frame_count == 0):
                return json.dumps({"success": False, "data": "Error in frame, no faces found"})

            # Release the video capture object and close all windows
            cap.release()
            cv2.destroyAllWindows()
            frame_count = 0

            # Update the progress bar
            if self.progress_callback:
                progress = (videos_processed / total_videos) * 100
                self.progress_callback(progress)

        return json.dumps({"success": True, "data": "Faces successfully cropped!"})
