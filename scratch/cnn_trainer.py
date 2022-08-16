import numpy as np
from PIL import Image
import cv2
import os
import pickle
import glob
import matplotlib.pyplot as plt
import time
from sklearn.model_selection import train_test_split

from convolutional import Convolutional
from activations import Sigmoid
from activations import Softmax
from entropy_losses import mse, mse_prime
from network import train, predict
from dense import Dense
from activations import Tanh
from reshape import Reshape

class cnn_train:
    def __init__(self):



        self.folder = os.path.dirname(os.path.abspath(__file__))
        self.image_files = os.path.join(self.folder, r"dataset\UTK_faces\crop_part1")

        self.label_ids = {}

        # for root, dirs, files in os.walk(self.image_files):
        #     for file in files:
        #         if file.endswith("png"):
        #             # self.color_space_module(ext=".png", _root=root, _dirs=dirs, _file=file)
        #         elif file.endswith("jpg"):
        #             # self.color_space_module(ext=".jpg", _root=root, _dirs=dirs, _file=file)
        #
        # with open("labels.pkl", 'wb') as f:
        #     pickle.dump(self.label_ids, f)

        image_data = []
        images = [cv2.imread(file) for file in glob.glob(r"dataset/UTK_faces/crop_part1/face/*.jpg")]
        for im in images:
            # convert images to grayscale
            im = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
            image_data.append(im)

        img_sizeX, img_sizeY = image_data[0].shape
        training_data, testing_data = train_test_split(image_data, test_size=0.2, random_state=25)


        network = [
            Convolutional((200, 200, 1), 3, 2),
            Sigmoid(),
            Reshape((5, 26, 26), (5 * 26 * 26, 1)),
            Dense(5 * 26 * 26, 100),
            Sigmoid(),
            Dense(100, 2),
            Sigmoid()
        ]
        print(network[0])

        Y = np.reshape([[0]], (1, 1, 1))
        train(network, mse, mse_prime, training_data, Y, epochs=3, learning_rate=0.1)

        # cv2.imshow('test1',training_data[0])
        # cv2.imshow('test2',testing_data[0])
        cv2.waitKey()
        cv2.destroyAllWindows()

        print(training_data[0])
        # print(len(testing_data))

        # decision boundary plot
        # points = []
        # for x in np.linspace(0, 1, 20):
        #     for y in np.linspace(0, 1, 20):
        #         z = predict(network, [[x], [y]])
        #         points.append([x, y, z[0, 0]])
        #
        # points = np.array(points)
        #
        # fig = plt.figure()
        # ax = fig.add_subplot(111, projection="3d")
        # ax.scatter(points[:, 0], points[:, 1], points[:, 2], c=points[:, 2], cmap="winter")
        # plt.show()


def main():
    cnn_train()

if __name__ == "__main__":
    start_time = time.process_time()
    main()
    print(time.process_time() - start_time, "seconds")
