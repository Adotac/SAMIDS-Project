import torch
from facenet_pytorch import InceptionResnetV1

# Load a pre-trained FaceNet model
model = InceptionResnetV1(pretrained='vggface2').eval()

from torchvision import transforms

# Define preprocessing transforms
data_transforms = transforms.Compose([
    transforms.Resize(160),
    transforms.CenterCrop(160),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

from facenet_pytorch import MTCNN

# Initialize MTCNN for face detection and alignment
mtcnn = MTCNN(image_size=160)

# Define the facial recognition pipeline
def facial_recognition_pipeline(image):
    # Detect and align faces in the image
    face = mtcnn(image)

    # If a face is detected, perform recognition
    if face is not None:
        with torch.no_grad():
            # Transform the face and pass it through the model
            face = data_transforms(face)
            face = face.unsqueeze(0)
            embedding = model(face)

        return embedding

    return None
