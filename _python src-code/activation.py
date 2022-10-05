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




class PReLU:
    r"""Applies the element-wise function:
    .. math::
        \text{PReLU}(x) = \max(0,x) + a * \min(0,x)
    or
    .. math::
        \text{PReLU}(x) =
        \begin{cases}
        x, & \text{ if } x \geq 0 \\
        ax, & \text{ otherwise }
        \end{cases}
    Here :math:`a` is a learnable parameter. When called without arguments, `nn.PReLU()` uses a single
    parameter :math:`a` across all input channels. If called with `nn.PReLU(nChannels)`,
    a separate :math:`a` is used for each input channel.
    .. note::
        weight decay should not be used when learning :math:`a` for good performance.
    .. note::
        Channel dim is the 2nd dim of input. When input has dims < 2, then there is
        no channel dim and the number of channels = 1.
    Args:
        num_parameters (int): number of :math:`a` to learn.
            Although it takes an int as input, there is only two values are legitimate:
            1, or the number of channels at input. Default: 1
        init (float): the initial value of :math:`a`. Default: 0.25
    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input
    Attributes:
        weight (Tensor): the learnable weights of shape (:attr:`num_parameters`).
    .. image:: ../scripts/activation_images/PReLU.png
    Examples::
         m = nn.PReLU()
         input = torch.randn(2)
         output = m(input)
    """
    # __constants__ = ['num_parameters']
    # num_parameters: int
    #
    # def __init__(self, num_parameters: int = 1, init: float = 0.25) -> None:
    #     self.num_parameters = num_parameters
    #     super(PReLU, self).__init__()
    #     self.weight = Parameter(torch.Tensor(num_parameters).fill_(init))
    #
    # def forward(self, input: Tensor) -> Tensor:
    #     return F.prelu(input, self.weight)
    #
    # def extra_repr(self) -> str:
    #     return 'num_parameters={}'.format(self.num_parameters)
    pass