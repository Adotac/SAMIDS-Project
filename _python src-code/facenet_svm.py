# ...
from facenet_pytorch import MTCNN, InceptionResnetV1, training
import torch
from torch.utils.data import DataLoader
from torchvision import datasets
import numpy as np
import os
from sklearn.svm import SVC
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

import onnx
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType

workers = 0 if os.name == 'nt' else 4

weights_path = './models/facenet-vggface2.pt'  # Replace with the correct path to your downloaded weights file
resnet = InceptionResnetV1()

# # Load the pre-trained weights, ignoring the extra keys
# state_dict = torch.load(weights_path)
# state_dict = {k: v for k, v in state_dict.items() if k not in ['logits.weight', 'logits.bias']}
# resnet.load_state_dict(state_dict, strict=False)
resnet.eval()

# Define a dataset and data loader
path = os.path.abspath('D:\Code Files\_dataset\lfwBiSAM')
dataset = datasets.ImageFolder(path)
dataset.samples = [
    (p, p.replace(path, path + '/data_aligned'))
    for p, _ in dataset.samples
]
loader = DataLoader(
    dataset,
    num_workers=workers,
    batch_size=1,
    collate_fn=training.collate_pil
)

# Perfom MTCNN facial detection and create aligned face tensors
# ...
aligned = []
names = []
for x, y in loader:
    x_aligned, prob = mtcnn(x, return_prob=True)
    if x_aligned is not None:
        # print(f'Face detected with probability: {prob.item():.4f}')
        aligned.append(x_aligned)
        names.append(y[0])
# ...


aligned = torch.stack(aligned).to(device)
names = np.array(names)

# Calculate the embeddings for the aligned faces
embeddings = resnet(aligned).detach().cpu()

# Encode the labels
le = LabelEncoder()
y = le.fit_transform(names)

# Split the dataset into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(embeddings, y, test_size=0.2, random_state=42)

# Train an SVM classifier
clf = SVC(kernel='linear', probability=True)
clf.fit(X_train, y_train)

# Evaluate the classifier
y_pred = clf.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy:.2f}")
