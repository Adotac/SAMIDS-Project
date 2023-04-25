import os
import cv2
import mediapipe as mp

# Define the MediaPipe face detection pipeline
mp_face_detection = mp.solutions.face_detection
face_detection = mp_face_detection.FaceDetection()

# Define the input video file
video_path = "./videodata"
# Define the output directory for your cropped face images
output_dir = "./dataset/cropped_raws"
os.makedirs(output_dir, exist_ok =True)

for filename in os.listdir(video_path):
    # Check if the file is a video file (e.g. .mp4, .avi, .mov)
    base_filename, file_extension = os.path.splitext(filename)
    # Check if the file is a video file (e.g. .mp4, .avi, .mov)
    if file_extension in ['.mp4', '.avi', '.mkv', '.m4v', '.mov']:

        # Construct the full file path
        filepath = os.path.join(video_path, filename)
        print(f'Reading file: {filepath}')

        # Open the video file
        cap = cv2.VideoCapture(filepath)

        # Loop through each frame in the video
        frame_count = 0

        # only read up to first 200 frames which equates to video clip under 10 seconds
        while frame_count < 100 and cap.isOpened():
        # Read the next frame from the video
            ret, frame = cap.read()

            # If the frame was successfully read
            if ret:
                # Convert the frame to grayscale
                gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

                # Run face detection on the frame
                results = face_detection.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))

                if results.detections:
                    # Loop through the detected faces and draw bounding boxes around them

                    for detection in results.detections:
                        bbox = detection.location_data.relative_bounding_box
                        x, y, w, h = int(bbox.xmin * frame.shape[1]), int(bbox.ymin * frame.shape[0]), int(
                            bbox.width * frame.shape[1]), int(bbox.height * frame.shape[0])

                        face_image = frame[y:y + h, x:x + w]

                        # Save the face region as a separate image
                        face_filename = base_filename + str(frame_count) + "_face_" + str(x) + "_" + str(y) + ".jpg"
                        face_path = os.path.join(output_dir, base_filename)
                        os.makedirs(face_path, exist_ok=True)

                        output_path = os.path.join(face_path, face_filename)
                        # os.makedirs(output_path, exist_ok=True)
                        print(output_path)

                        cv2.imwrite(output_path, face_image)

                        frame_count += 1
                        # cv2.imshow('Cropped face', face_image)

                else:
                    print("No faces detected on this file.")

                # Increment the frame count


            # If the frame was not successfully read, break out of the loop
            else:
                print("Failed to read a frame in this file.")
                break

        # Release the video capture object and close all windows
        cap.release()
        cv2.destroyAllWindows()
        frame_count = 0
