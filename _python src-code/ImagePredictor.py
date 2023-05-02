import torch
from facenet_pytorch import InceptionResnetV1
from torchvision import transforms
from PIL import Image
import cv2
import pickle
from collections import OrderedDict
import os

class ImagePredictor:
    def __init__(self, svm_path='svm_classifier.pkl', weights_path='./models/facenet-vggface2.pt'):
        self.svm_path = svm_path
        self.weights_path = weights_path

        self.data_transforms = transforms.Compose([
            # Add any custom augmentations here
            transforms.Resize((160, 160)),
            transforms.Grayscale(3),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])

        self.resnet = InceptionResnetV1()
        state_dict = torch.load(weights_path)
        filtered_state_dict = OrderedDict(
            (k, v) for k, v in state_dict.items() if k not in ['logits.weight', 'logits.bias'])
        self.resnet.load_state_dict(filtered_state_dict, strict=False)
        self.resnet.eval()

        with open(svm_path, "rb") as f:
            self.loaded_clf, self.loaded_le, self.loaded_name_list = pickle.load(f)

    def predict_label(self, frame):
        img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = Image.fromarray(img)
        img = self.data_transforms(img)
        img = img.unsqueeze(0)

        with torch.no_grad():
            embedding = self.resnet(img)

        label_index = self.loaded_clf.predict(embedding.numpy())[0]
        label_name = self.loaded_le.inverse_transform([label_index])[0]

        return label_name
