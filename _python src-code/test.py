import torch
from facenet_pytorch import InceptionResnetV1
from torchvision import transforms
import numpy as np
from PIL import Image
import cv2
import pickle
from CustomAugment import RandomBrightnessContrast
from collections import OrderedDict
# Define the path to the trained SVM model
svm_path = 'svm_classifier.pkl'

# Load the SVM model from the pickle file
with open("svm_classifier.pkl", "rb") as f:
    loaded_clf, loaded_le, loaded_name_list = pickle.load(f)

# Define the transformations to apply to the input image
# Define the transformations to apply to the input image
data_transforms = transforms.Compose([
    RandomBrightnessContrast(brightness_range=(0.9, 1.3), contrast_range=(0.6, 1)),
    transforms.Resize((160, 160)),
    transforms.Grayscale(3),
    transforms.ToTensor(),

    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])
import os

# Calculate the embedding of the face image using the pre-trained ResNet model
weights_path = './models/facenet-vggface2.pt'  # Replace with the correct path to your downloaded weights file
resnet = InceptionResnetV1()

# Load the pre-trained weights, ignoring the extra keys
state_dict = torch.load(weights_path)
filtered_state_dict = OrderedDict(
    (k, v) for k, v in state_dict.items() if k not in ['logits.weight', 'logits.bias'])
resnet.load_state_dict(filtered_state_dict, strict=False)
resnet.eval()

# List of image paths
image_folder = './dataset/test'
image_paths = [os.path.join(image_folder, img) for img in os.listdir(image_folder)]

url = 'http://192.168.43.245/800x600.jpg'
cap = cv2.VideoCapture(url)
while True:
    cap = cv2.VideoCapture(url)
    ret, frame = cap.read()
    # Iterate over image paths and predict the labels
    # for image_path in image_paths:
    # img = cv2.imread(image_path)
    cv2.imshow("Captured Frame", frame)
    # Convert the image to RGB format
    img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # Convert the image to a PIL image
    img = Image.fromarray(img)

    # Apply the transformations to the image
    img = data_transforms(img)

    # Add an extra dimension to the tensor to make it compatible with the model
    img = img.unsqueeze(0)

    with torch.no_grad():
        embedding = resnet(img)

    # Use the SVM model to predict the label of the image
    label_index = loaded_clf.predict(embedding.numpy())[0]
    label_name = loaded_le.inverse_transform([label_index])[0]

    print(f'The predicted label of the image is: {label_name}')
    # Exit the program if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cv2.destroyAllWindows()

cap.release()