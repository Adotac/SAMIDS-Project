import torch
from facenet_pytorch import InceptionResnetV1
from torchvision import transforms
import numpy as np
from PIL import Image
import cv2
import pickle

# Define the path to the trained SVM model
svm_path = 'svm_classifier.pkl'

# Load the SVM model from the pickle file
with open("svm_classifier.pkl", "rb") as f:
    loaded_clf, loaded_le, loaded_name_list = pickle.load(f)

# Define the transformations to apply to the input image
data_transforms = transforms.Compose([
    transforms.Resize((160, 160)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

# Load the input image
image_path = './dataset/test/test1.jpg'
img = cv2.imread(image_path)

# Convert the image to RGB format
img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

# Convert the image to a PIL image
img = Image.fromarray(img)

# Apply the transformations to the image
img = data_transforms(img)

# Add an extra dimension to the tensor to make it compatible with the model
img = img.unsqueeze(0)

# Calculate the embedding of the image using the pre-trained ResNet model
resnet = InceptionResnetV1(pretrained='vggface2').eval()
with torch.no_grad():
    embedding = resnet(img)

# Use the SVM model to predict the label of the image
label_index = loaded_clf.predict(embedding.numpy())[0]
label_name = loaded_le.inverse_transform([label_index])[0]

print(f'The predicted label of the image is: {label_name}')
