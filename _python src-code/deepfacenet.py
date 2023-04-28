import torch
import torch.nn as nn
from facenet_pytorch import InceptionResnetV1
import os
import random
from torch.utils.data import Dataset, DataLoader
from PIL import Image
from torchvision import transforms

import numpy as np
import matplotlib.pyplot as plt
from sklearn.manifold import TSNE


print(torch.version.cuda)
# Check if GPU is available
if torch.cuda.is_available():
    print("GPU is available!")
    # Check if a GPU is available and set the device accordingly
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    print(f"Using GPU: {torch.cuda.get_device_name(0)}")
    print(f"CUDA Version: {torch.version.cuda}")
else:
    print("GPU is not available. Using CPU instead.")
    device = torch.device("cpu")


weights_path = 'D:/Code Files/_models/facenet-vggface2.pt'  # Replace with the correct path to your downloaded weights file
resnet = InceptionResnetV1()

class TripletFaceDataset(Dataset):
    def __init__(self, root_dir, transform=None):
        self.root_dir = root_dir
        self.transform = transform
        self.classes, self.class_to_idx = self._find_classes(self.root_dir)
        self.image_list = self._load_image_list(self.root_dir)

    def _find_classes(self, root_dir):
        classes = [d.name for d in os.scandir(root_dir) if d.is_dir()]
        classes.sort()
        class_to_idx = {cls_name: i for i, cls_name in enumerate(classes)}
        return classes, class_to_idx

    def _load_image_list(self, root_dir):
        image_list = []
        for cls_name in self.classes:
            class_path = os.path.join(root_dir, cls_name)
            for img_name in os.listdir(class_path):
                img_path = os.path.join(class_path, img_name)
                image_list.append((img_path, cls_name))
        return image_list

    def __len__(self):
        return len(self.image_list)

    def __getitem__(self, index):
        anchor_path, anchor_class = self.image_list[index]
        positive_path, negative_path = self._get_positive_negative(anchor_class)

        anchor = Image.open(anchor_path)
        positive = Image.open(positive_path)
        negative = Image.open(negative_path)

        if self.transform:
            anchor = self.transform(anchor)
            positive = self.transform(positive)
            negative = self.transform(negative)

        return anchor, positive, negative

    def _get_positive_negative(self, anchor_class):
        positive_list = [img_path for img_path, cls_name in self.image_list if cls_name == anchor_class]
        negative_list = [img_path for img_path, cls_name in self.image_list if cls_name != anchor_class]

        positive_path = random.choice(positive_list)
        negative_path = random.choice(negative_list)

        return positive_path, negative_path


# Define the data transformations for your dataset
data_transforms = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

root_dir = os.path.abspath('D:\\Code Files\\_dataset\\lfwCustomBiSAM')
lfw_dataset = TripletFaceDataset(root_dir, transform=data_transforms)
lfw_dataloader = DataLoader(lfw_dataset, batch_size=32, shuffle=True, num_workers=4)

class TripletLoss(nn.Module):
    def __init__(self, margin=1.0):
        super(TripletLoss, self).__init__()
        self.margin = margin

    def forward(self, anchor, positive, negative):
        pos_dist = torch.sum((anchor - positive) ** 2, dim=1)
        neg_dist = torch.sum((anchor - negative) ** 2, dim=1)
        loss = torch.clamp(pos_dist - neg_dist + self.margin, min=0.0)
        return torch.mean(loss)

class DeepFaceFaceNetEmbeddings(nn.Module):
    def __init__(self):
        super(DeepFaceFaceNetEmbeddings, self).__init__()
        self.facenet = resnet.eval()

    def forward(self, x):
        x = self.facenet(x)
        return x

max_epoch = 10  # Replace with the number of classes in your dataset
model = DeepFaceFaceNetEmbeddings()
criterion = TripletLoss(margin=1.0)
optimizer = torch.optim.SGD(model.parameters(), lr=0.01, momentum=0.9)

import time

for epoch in range(max_epoch):
    start_time = time.time()  # Record the start time of the epoch

    for anchor, positive, negative in lfw_dataloader:
        print(time.time())
        # Move data to the appropriate device (CPU or GPU)
        anchor, positive, negative = anchor.to(device), positive.to(device), negative.to(device)

        # Zero the parameter gradients
        optimizer.zero_grad()

        # Forward pass to obtain embeddings
        anchor_embeddings = model(anchor)
        positive_embeddings = model(positive)
        negative_embeddings = model(negative)

        # Calculate triplet loss
        loss = criterion(anchor_embeddings, positive_embeddings, negative_embeddings)

        # Backward pass and optimization
        loss.backward()
        optimizer.step()

    end_time = time.time()  # Record the end time of the epoch
    epoch_time = end_time - start_time  # Calculate the time taken for the epoch
    print(f"Epoch {epoch + 1} took {epoch_time:.2f} seconds")

# Set the model to evaluation mode
model.eval()

# Create a list to store the embeddings and labels
embeddings = []
labels = []

# Iterate over the dataset (use a DataLoader without shuffling)
for images, batch_labels in lfw_dataloader:
    # Move the data to the appropriate device (CPU or GPU)
    images = images.to(device)

    # Obtain embeddings from the model
    with torch.no_grad():
        batch_embeddings = model(images)

    # Store the embeddings and labels
    embeddings.extend(batch_embeddings.cpu().numpy())
    labels.extend(batch_labels)

# Convert the embeddings and labels to NumPy arrays
embeddings = np.array(embeddings)
labels = np.array(labels)

tsne = TSNE(n_components=2, random_state=42)
tsne_embeddings = tsne.fit_transform(embeddings)

plt.figure(figsize=(10, 10))
scatter = plt.scatter(tsne_embeddings[:, 0], tsne_embeddings[:, 1], c=labels, cmap='tab10', s=50, alpha=0.8)
plt.legend(handles=scatter.legend_elements()[0], labels=list(set(labels)), title="Labels", loc="best")
plt.title("t-SNE plot of DeepFaceFaceNetEmbeddings")
plt.show()
