import os
import numpy as np
from cv2 import cv2
import matplotlib.pyplot as plt
import pickle
import math
from tqdm import tqdm
from random import shuffle

from conv_layer import ConvLayer
from max_pool_layer import MaxPoolLayer
from dense_layer import DenseLayer
from adam_optim import AdamOptim

class CNN:
    def __init__(self, model=False, architecture=False,
                 train=r'dataset/train/', test=r'dataset/test',
                 create_model=r'model/',name_model='SAMIDS_model', face_labels=False):
        self.arch = architecture
        self.init_adam = 0
        self.train_data = train
        self.test_data = test
        self.create_model = create_model
        self.name_model = name_model + '.pckl'

        if face_labels == False:
            f = open(self.create_model+self.name_model, 'rb')
            face_labels = pickle.load(f)
            f.close()

        self.face_labels = face_labels
        # example face = ['Dio', 'George']

        if model == False:
            self.obj = self.initial_object_layer()
        else:
            self.obj = model

        def initial_object_layer(self):
            object_layer = []
            for i, a in enum(self.arch):
                layer_type = a['layer_type']
                if layer_type == 'convolution':
                    obj