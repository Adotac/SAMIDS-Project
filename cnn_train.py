import numpy as np
import cv2
import  matplotlib.pyplot as plt

from conv import Conv
from maxpool import Max_Pool
from softmax import Softmax

def cnn_forward(img, label):
    out_p = Conv.forward( (img/255) - 0.5 )
    out_p = Max_Pool.forward(out_p)
    out_p = Softmax.forward(out_p)

    cross_entropy_loss =  -np.log(out_p[label])
    accuracy_val = 1 if np.argmax(out_p) == label else 0

    return  out_p, cross_entropy_loss, accuracy_val

def train_model(img, label, learning_rate=0.005):
    out, loss, acc = cnn_forward(img, label)

    gradient = np.zeros(10)
    gradient[label] = -1 / out[label]

    grad_back = Softmax.backward(gradient, learning_rate)
    grad_back = Max_Pool.backward(grad_back)
    grad_back = Conv.backward(grad_back, learning_rate)

    return loss, acc


for epoch in range(4):
    print("Epoch %d ===============>" % (epoch + 1))

    # training data shuffle
