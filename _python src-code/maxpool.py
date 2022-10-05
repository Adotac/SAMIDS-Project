import numpy as np

class Max_Pool:
    def __init__(self, kernel_size):
        self.kernel_size = kernel_size

    def image_region(self, img):
        new_h = img.shape[0] // self.kernel_size
        new_w = img.shape[1] // self.kernel_size
        self.image = img

        for i in range(new_h):
            for j in range(new_w):
                image_patch = img[ (i*self.kernel_size) : (i*self.kernel_size + self.kernel_size), (j*self.kernel_size) : (j*self.kernel_size + self.kernel_size) ]
                yield image_patch, i ,j

    def forward(self, img):
        h, w, num_kernel = img.shape
        output = np.zeros( (h // self.kernel_size, w // self.kernel_size, num_kernel) )

        for image_patch, i, j in self.image_region(img):
            output[i. j] = np.amax(image_patch, axis = (0, 1) )

        return output

    def backward(self, dL_dout):
        dL_dmax_pool = np.zeros(self.image.shape)

        for image_patch, i, j in self.image_region(self.image):
            h, w, num_kernel = image_patch.shape
            max_val = np.amax(image_patch, axis = (0, 1))

            for m in range(h):
                for n in range(w):
                    for p in range(num_kernel):
                        if image_patch[m, n, p] == max_val[p]:
                            dL_dmax_pool[ i*self.kernel_size + m, j*self.kernel_size + n, p ] = dL_dout[i, j, p]

            return dL_dmax_pool

