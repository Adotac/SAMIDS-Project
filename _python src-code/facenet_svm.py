import os
import time
import gc
import pickle
import cv2
import torch
import numpy as np
from PIL import Image
from collections import OrderedDict
from sklearn.svm import SVC
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from torchvision import datasets
import torchvision.transforms as transforms
from torch.utils.data import DataLoader
from facenet_pytorch import InceptionResnetV1

from CustomAugment import RandomFlip, RandomRotation, RandomBrightnessContrast, Normalize
import mediapipe as mp


class FaceRecognition:

    def __init__(self):
        self.device = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')
        self.face_detection = mp.solutions.face_detection.FaceDetection(model_selection=0, min_detection_confidence=0.6)
        self.weights_path = './models/facenet-vggface2.pt'

    def elapsedTime(self, start_time):
        end_time = time.time()
        elapsed_time = end_time - start_time
        print(f"\nElapsed time: {elapsed_time:.2f} seconds")

    def collate_np(self, batch, class_to_idx):
        images, labels = zip(*batch)
        target_size = (160, 160)
        images_np = [cv2.resize(np.array(img), target_size) for img in images]
        labels_str = [list(class_to_idx.keys())[list(class_to_idx.values()).index(label)] for label in labels]
        return images_np, labels_str

    def train(self):
        start_time = time.time()

        print(f'Running on device: {self.device}')

        resnet = InceptionResnetV1()

        state_dict = torch.load(self.weights_path)
        filtered_state_dict = OrderedDict((k, v) for k, v in state_dict.items() if k not in ['logits.weight', 'logits.bias'])
        resnet.load_state_dict(filtered_state_dict, strict=False)

        resnet.eval()

        path = './dataset/videos_cropped'

        data_transforms = transforms.Compose([
            RandomRotation(angles=(-10, -5, 0, 5, 10)),
            RandomFlip(p=0.5),
            RandomBrightnessContrast(brightness_range=(0.8, 1.5), contrast_range=(0.6, 1.5)),
            transforms.Resize((160, 160)),
            Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])

        if os.path.exists(path):
            dataset = datasets.ImageFolder(path, transform=data_transforms)
        else:
            print("Path doesn't exist")
            return

        idx_to_class = {i: c for c, i in dataset.class_to_idx.items()}

        workers = 0 if os.name == 'nt' else 4
        loader = DataLoader(dataset,
                            batch_size=32,
                            shuffle=True,
                            num_workers=workers,
                            collate_fn=lambda batch: self.collate_np(batch, dataset.class_to_idx)
                            )

        face_list = []  # list of cropped faces from photos folder
        name_list = []  # list of names corrospoing to cropped photos

        self.elapsedTime(start_time)
        for batch_idx, (inputs, labels) in enumerate(loader):
            # print(idx_to_class[idx[0]])
            print("Batch #: " + str(batch_idx))

            batch_size = len(inputs)  # Get the current batch size (may be smaller for the last batch)
            for j in range(batch_size):
                img = inputs[j]  # Get the j-th image in the batch
                label = labels[j]  # Get the j-th label in the batch

                img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

                try:
                    results = self.face_detection.process(img)
                    # face, prob = mtcnn(img, return_prob=True)

                    if results.detections:
                        # Get the first detected face
                        first_face = results.detections[0]

                        bbox = first_face.location_data.relative_bounding_box
                        x, y, w, h = int(bbox.xmin * img.shape[1]), int(bbox.ymin * img.shape[0]), \
                                     int(bbox.width * img.shape[1]), int(bbox.height * img.shape[0])

                        # Add padding to the image
                        border = max(w, h)  # Use the maximum of width and height as the border size
                        img_padded = cv2.copyMakeBorder(img, border, border, border, border, cv2.BORDER_CONSTANT,
                                                        value=[0, 0, 0])

                        # Crop the face region from the padded image
                        face_image = img_padded[y + border:y + h + border, x + border:x + w + border]

                        # Convert the cropped face from OpenCV's BGR format to RGB format
                        face_image = cv2.cvtColor(face_image, cv2.COLOR_BGR2RGB)
                        # Convert the NumPy array to a PyTorch tensor
                        face_image = torch.from_numpy(face_image).permute(2, 0, 1).float()

                        # print(f'Face detected with probability: {prob.item():.4f}')
                        face_list.append(face_image)
                        name_list.append(label)  # names are stored in a list
                        # elapsedTime(start_time)
                        # print(idx_to_class[label])
                        print(str(j), end='')
                    else:
                        print('.', end='')
                        # print(idx_to_class[label])
                        # print("No Face detected!")
                        # pass
                except ValueError:
                    print("Error detection!")
                    continue

                # Perform garbage collection to free up memory
                del img
                gc.collect()

            self.elapsedTime(start_time)

        # ...

        print("Face detection complete...")
        self.elapsedTime(start_time)

        face_list_resized = []
        for face in face_list:
            face_np = face.numpy().transpose((1, 2, 0))  # Convert tensor to NumPy array and change channel order
            face_pil = Image.fromarray(face_np.astype('uint8'))  # Convert NumPy array to PIL image
            face_pil_resized = face_pil.resize((160, 160), Image.ANTIALIAS)  # Resize the PIL image
            face_resized = transforms.ToTensor()(face_pil_resized)  # Convert the resized PIL image back to a tensor
            face_list_resized.append(face_resized)

        # print(face_list)
        if len(face_list_resized) > 0:
            aligned = torch.stack(face_list_resized)
            # Continue with the rest of the code
        else:
            print("No faces were found in the dataset. Please check the input images.")
            return

        names = np.array(name_list)

        # Disable gradient calculation during inference
        with torch.no_grad():
            # Calculate the embeddings for the aligned faces
            embeddings = resnet(aligned).detach().cpu()

        # Encode the labels
        le = LabelEncoder()
        y = le.fit_transform(names)

        print("Training SVM...")
        self.elapsedTime(start_time)
        # Split the dataset into training and testing sets
        X_train, X_test, y_train, y_test = train_test_split(embeddings, y, test_size=0.2, random_state=42)

        # Train an SVM classifier
        clf = SVC(kernel='linear', probability=True)
        clf.fit(X_train, y_train)

        # Save the trained model and the name list as a pickle file
        with open("svm_classifier.pkl", "wb") as f:
            pickle.dump((clf, le, name_list), f)

        # Load the trained model and the name list from the pickle file
        with open("svm_classifier.pkl", "rb") as f:
            loaded_clf, loaded_le, loaded_name_list = pickle.load(f)

        # Evaluate the classifier
        y_pred = loaded_clf.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        print(f"Accuracy: {accuracy:.2f}")
        self.elapsedTime(start_time)

        #
        # embedding_list = loaded_clf[0]
        # name_list = loaded_clf[1]

if __name__ == '__main__':
    face_recognition = FaceRecognition()
    face_recognition.train()
