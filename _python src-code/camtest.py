import torch
from facenet_pytorch import InceptionResnetV1
from torchvision import transforms
import numpy as np
from PIL import Image
import cv2
import pickle
import mediapipe as mp
from collections import OrderedDict
from CustomAugment import RandomBrightnessContrast

# Define the path to the trained SVM model
svm_path = './j-notebooks/svm-rbf_classifier.pkl'

# Load the SVM model from the pickle file
with open(svm_path, "rb") as f:
    loaded_clf, loaded_le, loaded_name_list = pickle.load(f)

# Calculate the embedding of the face image using the pre-trained ResNet model
weights_path = './models/facenet-vggface2.pt'  # Replace with the correct path to your downloaded weights file
resnet = InceptionResnetV1()

# Load the pre-trained weights, ignoring the extra keys
state_dict = torch.load(weights_path)
filtered_state_dict = OrderedDict(
    (k, v) for k, v in state_dict.items() if k not in ['logits.weight', 'logits.bias'])
resnet.load_state_dict(filtered_state_dict, strict=False)
resnet.eval()

# Define the transformations to apply to the input image
data_transforms = transforms.Compose([
    RandomBrightnessContrast(brightness_range=(0.7, 8), contrast_range=(0.6, 1)),
    transforms.Resize((160, 160)),
    transforms.Grayscale(3),
    transforms.ToTensor(),

    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

# Initialize Mediapipe face detection module
face_detection = mp.solutions.face_detection.FaceDetection()

# Initialize the video capture device
cap = cv2.VideoCapture(0)

while True:
    # Capture a frame from the video feed
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

            # Convert the face image to a PIL image
            face_image = Image.fromarray(face_image)

            # Apply the transformations to the image
            face_image = data_transforms(face_image)

            # Add an extra dimension to the tensor to make it compatible with the model
            face_image = face_image.unsqueeze(0)

            with torch.no_grad():
                embedding = resnet(face_image)

            # Use the SVM model to predict the label of the face image
            label_index = loaded_clf.predict(embedding.numpy())[0]
            label_name = loaded_le.inverse_transform([label_index])[0]

            # Draw the predicted label on the frame
            cv2.putText(frame, label_name, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

    # Display the resulting frame
    cv2.imshow('Face recognition', frame)

    # Exit the program if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
