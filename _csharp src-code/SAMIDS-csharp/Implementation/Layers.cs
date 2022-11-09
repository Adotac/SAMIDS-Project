using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


using Numpy;
using ns = NumSharp;
using SharpCV;
using static SharpCV.Binding;

namespace SAMIDS_csharp.Implementation
{
    internal interface Layers
    {
        /// To group Conv Layer, DenseLayer, and Max pooling layer
    }

    public class ConvLayer: Layers{
        private int filter_length;
        private int stride;
        private (int, int) kernel_size;
        private int padding;
        private string activation;

        private NDarray input, inp_with_pad, output, activated_output;
        private (bool flag, NDarray val) filters;
        

        ConvLayer(
            int filter_length,
            int kernel_size,
            int stride = 1,
            int padding = 1,
            string activation = "relu"
            ) {

            this.filter_length = filter_length;
            this.kernel_size = (kernel_size, kernel_size);
            this.stride = stride;
            this.padding = padding;
            this.activation = activation;

            this.filters = (false, np.zeros());
        }

        public void setInput(NDarray inp)
        {
            this.input = inp;
            this.inp_with_pad = setPadding(inp);
            if (this.filters.flag == false) {
                this.filters = (true, np.random.randn(this.filter_length, inp.shape[0], this.kernel_size.Item1, this.kernel_size.Item2)
                    * np.sqrt(
                        np.array(new double[] { 1/(this.kernel_size.Item1 * this.kernel_size.Item2) }) 
                        )
                    );
            }
            
        }

        private NDarray setPadding(NDarray inp) {
            if (this.padding > 0)
            {
                using (var output = np.empty()) // Chech or try to debug values before the append
                {
                    foreach (var i in Utils.Range(inp.shape[0]))
                    {
                        output.append(np.pad(inp[i], np.array(new int[]{this.padding, this.padding}), mode: "constant_values"));
                    }
                    return output;
                }
            }
            else
                return inp;

        }

        private NDarray unpad(NDarray inp)
        {
            if (this.padding != 1)
            {
                return np.array(inp);
            }
            else
            {       
                using (var output = np.empty()) // Chech or try to debug values before the append
                {
                    /*foreach (var i in inp.nEnumerate())
                    {
                        i. = np.delete(i, -1, 0);
                        i = np.delete(i, 0, 0);
                        i = np.delete(i, -1, 1);
                        i = np.delete(i, 0, 1);
                        output.append(i);
                    }*/
                    for (int i = 0; i < inp.shape.Dimensions[0]; i++)
                    {
                        inp[i] = np.delete(inp[i], -1, 0);
                        inp[i] = np.delete(inp[i], 0, 0);
                        inp[i] = np.delete(inp[i], -1, 1);
                        inp[i] = np.delete(inp[i], 0, 1);
                        output.append(inp[i]);
                    }

                    return output;
                }
                
            }
        }

        private NDarray relu(NDarray inp) { // Should be changed into prelu after experimental code
            return np.maximum((NDarray)0, inp);
        }

        public NDarray forward() {
            var x_OutputSize = (int)Math.Floor( (double)(this.input.shape[1] + (2*this.padding) - this.filters.val.shape[2]) / this.stride ) + 1;
            var y_OutputSize = (int)Math.Floor( (double)(this.input.shape[2] + (2*this.padding) - this.filters.val.shape[3]) / this.stride ) + 1;
            var output = np.zeros( this.filters.val.shape[0], x_OutputSize, y_OutputSize );
            var input_with_pad = np.copy(this.inp_with_pad);

            foreach (var x in Utils.Range(this.filters.val.shape[0])) {
                var filter = np.array(this.filters.val[x], copy: true);

                foreach (var i in Utils.Range(x_OutputSize)) {
                    foreach (var j in Utils.Range(y_OutputSize))
                    {
                        NDarray convolution = (NDarray)0;

                        foreach (var k in Utils.Range(filter.shape[1]))
                        {
                            foreach (var l in Utils.Range(filter.shape[2]))
                            {
                                foreach (var m in Utils.Range(this.filters.val.shape[1]))
                                {
                                    convolution += (filter[m][k][l] * this.inp_with_pad[m][i*this.stride+k][j*this.stride+l]);
                                }

                            }

                        }
                        output[x][i][j] = convolution;
                    }
                }
            }

            this.output = np.array(output, copy: true);
            var activated_output = this.relu(output);
            this.activated_output = np.array(activated_output, copy: true);

            return activated_output;
        }

        private NDarray backward_RelU(NDarray dz_input) {
            var dz = np.array(dz_input, copy: true);
            var dr = np.where(this.output > 0, dz, (NDarray)0);

            return dr;
        }

        private NDarray backward_filters(NDarray da_input) {
            var dfilters = np.zeros((this.filters.val.shape));

            foreach (var i in Utils.Range(da_input.shape[0])) {
                foreach (var j in Utils.Range(this.inp_with_pad.shape[0])) {
                    var inp_w_pad = np.array(this.inp_with_pad, copy: true);

                    foreach (var k in Utils.Range(this.filters.val.shape[2])) {
                        foreach (var l in Utils.Range(this.filters.val.shape[3])) {
                            var convolution = (NDarray)0;

                            foreach (var m in Utils.Range(da_input.shape[1]))
                            {
                                foreach (var n in Utils.Range(da_input.shape[2]))
                                {
                                    convolution += (inp_w_pad[j][k * this.stride + m][l * this.stride + n] * da_input[i][m][n]);
                                }

                            }
                            dfilters[i][j][k][l] = convolution;
                        }
                    }
                }
            }

            dfilters = np.array(dfilters, copy: true);
            return dfilters;
        }

        private NDarray input_backward(NDarray da_input) {
            NDarray dinput = np.zeros();

            var input = np.zeros((this.inp_with_pad.shape));
            var rotate180Filter = np.rot90(np.array(this.filters.val, copy: true), 2, axes:new int[] { 2, 3 });

            var pad_size = rotate180Filter.shape[2] - 1;
            var da_with_pad = np.pad(np.array(da_input, copy: true), pad_width: np.array(new int[,] { {0,0}, {pad_size, pad_size}, { pad_size, pad_size } }), mode: "constant");

            var irandom = StaticRandom.Instance.Next(0, da_input.shape[0]-1);

            foreach (var i in Utils.Range(this.inp_with_pad.shape[0])) {
                foreach (var j in Utils.Range(this.inp_with_pad.shape[1])){
                    foreach (var k in Utils.Range(this.inp_with_pad.shape[2]))
                    {
                        var convolution = (NDarray)0;
                        foreach (var l in Utils.Range(rotate180Filter.shape[2]))
                        {
                            foreach (var m in Utils.Range(rotate180Filter.shape[3]))
                            {
                                convolution += (da_with_pad[irandom][j * this.stride + l][k * this.stride + m] * rotate180Filter[i][l][m]);
                            }
                        }
                        input[i][j][k] = convolution;
                    }
                }
            }

            if (this.padding != 0) { 
                dinput = this.unpad(input);
            }
            return dinput;
        }

        public NDarray backward(NDarray da_input) {
            var dc = this.backward_RelU(da_input);
            var di = this.input_backward(dc);
            return di;
        }

        public NDarray gradient_function(NDarray dz_input) {
            var dk = this.backward_filters(dz_input);
            return dk;
        }
    }

}
