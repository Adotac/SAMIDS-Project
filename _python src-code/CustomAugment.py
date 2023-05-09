import cv2
import numpy as np
from PIL import Image

import random

class RandomAugmentation:
    def __init__(self, 
                 brightness_range=(0.5, 1.5), 
                 contrast_range=(0.5, 1.5), 
                 #-----------------------#
                 mean=0.0, 
                 std_range=(0.01, 0.8), 
                 #-----------------------#
                 p_flip=0.5, 
                 #-----------------------#
                 angles=(-20, -1, 0, 1, 20)):
        self.augmentations = [
            RandomBrightnessContrast(brightness_range, contrast_range),
            RandomGaussianNoise(mean, std_range),
            RandomRotation(angles),
            RandomFlip(p_flip)
        ]

    def __call__(self, img):
        random.shuffle(self.augmentations)
        for augmentation in self.augmentations:
            if random.random() < 0.5:
                img = augmentation(img)
        return img


class RandomRotation:
    def __init__(self, angles):
        self.angles = angles

    def __call__(self, img):
        angle = np.random.choice(self.angles)
        img = img.rotate(angle)
        return img

class RandomFlip:
    def __init__(self, p=0.5):
        self.p = p

    def __call__(self, img):
        if np.random.random() < self.p:
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
        return img

class RandomBrightnessContrast:
    def __init__(self, brightness_range=(0.5, 1.5), contrast_range=(0.5, 1.5)):
        self.brightness_range = brightness_range
        self.contrast_range = contrast_range

    def __call__(self, img):
        brightness = np.random.uniform(self.brightness_range[0], self.brightness_range[1])
        contrast = np.random.uniform(self.contrast_range[0], self.contrast_range[1])
        img = Image.fromarray(cv2.convertScaleAbs(np.array(img), alpha=contrast, beta=brightness))
        return img
    
class RandomGaussianNoise:
    def __init__(self, mean=0.0, std_range=(0.01, 0.1)):
        self.mean = mean
        self.std_range = std_range

    def __call__(self, img):
        img_np = np.array(img)
        std = np.random.uniform(self.std_range[0], self.std_range[1])
        noise = np.random.normal(self.mean, std, img_np.shape)
        img_np_with_noise = np.clip(img_np + noise, 0, 255).astype(np.uint8)
        img_with_noise = Image.fromarray(img_np_with_noise)
        return img_with_noise
 
class Normalize:
    def __init__(self, mean, std):
        self.mean = np.array(mean)
        self.std = np.array(std)

    def __call__(self, img):
        img = np.array(img).astype(np.float32) / 255.0
        assert img.shape[-1] == len(self.mean) == len(self.std), "Number of channels in the image should match the length of mean and std"
        normalized_image = (img - self.mean) / self.std
        normalized_image = np.clip(normalized_image, 0, 1)  # Clip the values to the [0, 1] range
        normalized_image = (normalized_image * 255).astype('uint8')  # Scale the values to the [0, 255] range and convert to integers
        img = Image.fromarray(normalized_image.astype('uint8'), 'RGB')  # Convert the NumPy array to a PIL image
        return img


