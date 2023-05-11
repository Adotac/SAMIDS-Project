import torch
from facenet_pytorch import InceptionResnetV1
from torchvision import transforms
from PIL import Image
import cv2
import pickle
import mediapipe as mp
from collections import OrderedDict

import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import numpy as np
import os

from CustomAugment import RandomBrightnessContrast

class ImagePredictor:
    def __init__(self, svm_path='svm_classifier-main.pkl', weights_path='./models/facenet-vggface2.pt'):
        self.svm_path = svm_path
        self.weights_path = weights_path

        self.data_transforms = transforms.Compose([
            # Add any custom augmentations here
            RandomBrightnessContrast(brightness_range=(0.8, 1.2), contrast_range=(0.8, 1.2)),
            transforms.ColorJitter(saturation=0.1, hue=0.1),
            transforms.Resize((160, 160)),
            # transforms.Grayscale(3),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])

        self.rotation = 0 # need to rotate due to esp32cam is rotated 90 degrees, set to 0 if your camera has correct rotation

        self.resnet = InceptionResnetV1()
        state_dict = torch.load(weights_path)
        filtered_state_dict = OrderedDict(
            (k, v) for k, v in state_dict.items() if k not in ['logits.weight', 'logits.bias'])
        self.resnet.load_state_dict(filtered_state_dict, strict=False)
        self.resnet.eval()

        with open(svm_path, "rb") as f:
            self.loaded_clf, self.loaded_le, self.loaded_name_list, _,_,_,_ = pickle.load(f)

    def predict_label(self, frame):
        # img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = Image.fromarray(frame)
        img = img.rotate(self.rotation)
        img = self.data_transforms(img)
        # tensorShow(img);

        img = img.unsqueeze(0)

        with torch.no_grad():
            embedding = self.resnet(img)

        label_index = self.loaded_clf.predict(embedding.numpy())[0]
        label_name = self.loaded_le.inverse_transform([label_index])[0]

        return label_name

    def predict_display(self, ip):
        # Initialize Mediapipe face detection module
        # url = f'http://{ip}/240x240.jpg'
        url = f'http://{ip}/320x240.jpg'
        # url = f'http://{ip}/800x600.jpg'
        face_detection = mp.solutions.face_detection.FaceDetection()
        cap = cv2.VideoCapture(url)
        if not cap.isOpened():
            print("Failed to open the video stream.")
        else:
            while True:
                cap = cv2.VideoCapture(url)
                ret, frame = cap.read()
                if not ret:
                    break

                # Convert the frame to RGB format
                img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    
                # Detect faces using Mediapipe
                results = face_detection.process(img)

                if results.detections:
                    # Iterate through the detected faces and crop them from the frame
                    for detection in results.detections:
                        bbox = detection.location_data.relative_bounding_box
                        x, y, w, h = int(bbox.xmin * img.shape[1]), int(bbox.ymin * img.shape[0]), \
                                     int(bbox.width * img.shape[1]), int(bbox.height * img.shape[0])

                        # Add padding to the image
                        border = max(w, h)  # Use the maximum of width and height as the border size
                        img_padded = cv2.copyMakeBorder(img, border, border, border, border, cv2.BORDER_CONSTANT,
                                                        value=[0, 0, 0])

                        # Crop the face region from the padded image
                        face_image = img_padded[y + border:y + h + border, x + border:x + w + border]

                        label_name = self.predict_label(face_image)

                        # Draw the predicted label on the frame
                        cv2.putText(frame, label_name, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
                        print(f'The predicted label of the image is: {label_name}')
                cv2.imshow("Captured Frame", frame)

                # Exit the program if 'q' is pressed
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

        cv2.destroyAllWindows()
        cap.release()


def tensorShow(img):

    # Convert the tensor to NumPy array
    img_np = img.numpy()

    # If the tensor has shape (channels, height, width), transpose it to (height, width, channels)
    if img_np.shape[0] == 3 or img_np.shape[0] == 1:
        img_np = img_np.transpose((1, 2, 0))

    # Convert the image to the correct color space (if necessary)
    img_np = cv2.cvtColor(img_np, cv2.COLOR_RGB2BGR)

    # Display the image
    cv2.imshow("Augmented Frame", img_np)

    # Break the loop if the 'q' key is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        return
            