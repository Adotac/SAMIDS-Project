import numpy as np

class Softmax:
    def __init__(self, imput_node, softmax_node):
        self.weight = np.random.randn( imput_node, softmax_node ) / imput_node
        self.bias = np.zeros(softmax_node)

    def forward(self, img):
        self.orig_img_shape = img.shape
        image_modified = img.flatten()
        self.modified_input = image_modified

        output_val = np.dot(image_modified, self.weight) + self.bias
        self.out = output_val

        exp_out = np.exp(output_val)
        return exp_out/np.sum(exp_out, axis = 0)

    def backward(self, dL_dout, learning_rate):
        dL_db = 1
        for i, grad in enumerate(dL_dout):
            if grad == 0:
                continue

            transformation_eq = np.exp(self.out)
            S_total = np.sum(transformation_eq)

            # gradients w/ respect to output z
            dy_dz = -transformation_eq[i] * transformation_eq / (S_total **2)
            dy_dz[i] = transformation_eq[i] * (S_total - transformation_eq[i]) / (S_total **2)

            # gradients of totals against weight/biases/inputs
            dz_dw = self.modified_input
            dz_db = 1
            dz_d_inp = self.weight

            # gradient of loss against totals
            dL_dz = grad * dy_dz

            # gradients of loss against biases/weights/inputs
            dL_dw = dz_dw[np.newaxis].T @ dL_dz[np.newaxis]
            dL_db = dL_dz * dL_db
            dL_d_inp = dz_d_inp @ dL_dz

            # update weights and biases
            self.weight -= learning_rate * dL_dw
            self.bias -= learning_rate * dL_db

            return dL_d_inp.reshape(self.orig_img_shape)