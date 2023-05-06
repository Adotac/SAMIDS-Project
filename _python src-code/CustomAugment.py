import cv2
import numpy as np
from PIL import Image

import torch
import torchvision.transforms.functional as TF

class CutMix:
    def __init__(self, img_size, alpha=0.25, beta=0.25):
        self.img_size = img_size
        self.alpha = alpha
        self.beta = beta

    def sample_beta_distribution(self, size):
        gamma_1_sample = torch.randn(size) * self.beta
        gamma_2_sample = torch.randn(size) * self.alpha
        return gamma_1_sample / (gamma_1_sample + gamma_2_sample)

    def get_box(self, lambda_value):
        cut_rat = torch.sqrt(1.0 - lambda_value)

        cut_w = self.img_size * cut_rat
        cut_w = torch.tensor(cut_w, dtype=torch.int32)

        cut_h = self.img_size * cut_rat
        cut_h = torch.tensor(cut_h, dtype=torch.int32)

        cut_x = torch.randint(0, self.img_size, (1,), dtype=torch.int32)
        cut_y = torch.randint(0, self.img_size, (1,), dtype=torch.int32)

        boundaryx1 = torch.clamp(cut_x[0] - cut_w // 2, 0, self.img_size)
        boundaryy1 = torch.clamp(cut_y[0] - cut_h // 2, 0, self.img_size)
        bbx2 = torch.clamp(cut_x[0] + cut_w // 2, 0, self.img_size)
        bby2 = torch.clamp(cut_y[0] + cut_h // 2, 0, self.img_size)

        target_h = bby2 - boundaryy1
        if target_h == 0:
            target_h += 1

        target_w = bbx2 - boundaryx1
        if target_w == 0:
            target_w += 1

        return boundaryx1, boundaryy1, target_h, target_w

    def cutmix(self, train_ds_one, train_ds_two):
        (image1, label1), (image2, label2) = train_ds_one, train_ds_two

        # Get a sample from the Beta distribution
        lambda_value = self.sample_beta_distribution(1)

        # Define Lambda
        lambda_value = lambda_value[0][0].item()

        # Get the bounding box offsets, heights and widths
        boundaryx1, boundaryy1, target_h, target_w = self.get_box(lambda_value)

        # Get a patch from the second image (`image2`)
        crop2 = TF.crop(image2, boundaryy1, boundaryx1, target_h, target_w)
        # Pad the `image2` patch (`crop2`) with the same offset
        image2 = TF.pad(crop2, (boundaryx1, boundaryy1, self.img_size - target_w - boundaryx1, self.img_size - target_h - boundaryy1))

        # Get a patch from the first image (`image1`)
        crop1 = TF.crop(image1, boundaryy1, boundaryx1, target_h, target_w)
        # Pad the `image1` patch (`crop1`) with the same offset
        img1 = TF.pad(crop1, (boundaryx1, boundaryy1, self.img_size - target_w - boundaryx1, self.img_size - target_h - boundaryy1))

        # Modify the first image by subtracting the patch from `image1`
        # (before applying the `image2` patch)
        image1 = image1 - img1
        # Add the modified `image1` and `image2` together to get the CutMix image
        image = image1 + image2

        # Adjust Lambda in accordance to the pixel ratio
        lambda_value = 1 - (target_w * target_h) / (self.img_size * self.img_size)
        lambda_value = torch.tensor(lambda_value, dtype=torch.float32)

        # Combine the labels of both images
        label = lambda_value * label1 + (1 - lambda_value) * label2
        return image, label


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


