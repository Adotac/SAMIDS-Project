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

        private NDarray input, inp_with_pad;
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

        public void forward() {
            var x_OutputSize = (int)Math.Floor( (double)(this.input.shape[1] + (2*this.padding) - this.filters.val.shape[2]) / this.stride ) + 1;
            var y_OutputSize = (int)Math.Floor( (double)(this.input.shape[2] + (2*this.padding) - this.filters.val.shape[3]) / this.stride ) + 1;
            var output = np.zeros( this.filters.val.shape[0], x_OutputSize, y_OutputSize );
            var input_with_pad = np.copy(this.inp_with_pad);

            foreach (var x in Utils.Range(this.filters.val.shape[0])) {
                var filter = np.array(this.filters.val[x], copy: true);

                foreach (var i in Utils.Range(x_OutputSize)) {
                    foreach (var j in Utils.Range(y_OutputSize))
                    {
                        var convolution = 0;

                        foreach (var k in Utils.Range(filter.shape[1]))
                        {
                            foreach (var l in Utils.Range(filter.shape[2]))
                            {
                                foreach (var m in Utils.Range(this.filters.val.shape[1]))
                                {
                                    //convolution += (filter[m][k][l] * this.inp_with_pad[m][i*this.stride+k][j*this.stride+l]);

                                }

                            }

                        }
                    }
                }
            }

        }
    }
}
