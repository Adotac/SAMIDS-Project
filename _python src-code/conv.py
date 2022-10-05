import numpy as np
import math
import

class Conv3D:
    def __init__(self,
                 num_kernel, kernel_size,
                 in_channels: int,
                 out_channels:int,
                 stride=1,
                 padding=1,
                 dilation=1,


                 activation='relu'):
        self.num_kernel = num_kernel # filter length
        self.kernel_size = kernel_size
        self.conv_filter = np.random.randn(num_kernel, kernel_size, kernel_size)/(kernel_size, * kernel_size)

        self.filters = False
        self.stride = stride
        self.activation=activation
        self.padding=padding
        self.output=[]
        self.output_activated = []
        self.d1z=[]

    def set_input

    def image_region(self, img):
        h, w = img.shape
        self.image = img

        for i in range(h - self.kernel_size + 1):
            for j in range(w - self.kernel_size + 1):
                image_patch = img[ i: (i + self.kernel_size), j: (j + self.kernel_size) ]
                yield image_patch, i, j

    def forward(self, img):
        h, w = img.shape
        conv_out = np.zeros( (h - self.kernel_size + 1, w - self.kernel_size + 1, self.num_kernel) )
        for image_patch, i, j, in self.image_region(img):
            conv_out[i, j] = np.sum( image_patch * self.conv_filter, axis=(1,2) )
        return conv_out

    def backward(self, dL_dout, learning_rate):
        dL_dF_params = np.zeros(self.conv_filter.shape)

        for image_patch, i, j, in self.image_region(self.image):
            for k in range(self.num_kernel):
                dL_dF_params[k] += image_patch*dL_dout[i, j, k]

        #update kernel params
        self.conv_filter -= learning_rate * dL_dF_params
        return dL_dF_params