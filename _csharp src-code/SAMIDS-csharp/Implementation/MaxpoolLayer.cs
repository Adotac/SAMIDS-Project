using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Numpy;

namespace SAMIDS_csharp.Implementation
{
    internal class MaxpoolLayer
    {
        private (int, int) poolSize;
        private int stride;
        private int padding;

        private NDarray maxPool_index;

        private NDarray input, inp_with_pad, output;

        public MaxpoolLayer(
            int poolSize,
            int stride = 0,
            int padding = 2
            )
        {

            this.poolSize = (poolSize, poolSize);
            this.stride = stride;
            this.padding = padding;
        }

        public void setInput(NDarray input) { 
            this.input = input;
            this.inp_with_pad = this.setPadding(input, this.padding);
            this.maxPool_index = new int[] { };
        }

        private NDarray setPadding(NDarray inp, int padding)
        {
            if (this.padding > 0)
            {
                using (var output = np.empty()) // Chech or try to debug values before the append
                {
                    foreach (var i in Utils.Range(inp.shape[0]))
                    {
                        output.append(np.pad(inp[i], np.array(new int[] { this.padding, this.padding }), mode: "constant_values"));
                    }
                    return output;
                }
            }
            else
                return inp;

        }

        private NDarray unpad(NDarray inp)
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
                for (int i = 0; i < inp.shape[0]; i++)
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

        public NDarray forward()
        {
            var x_OutputSize = (int)Math.Floor((double)(this.input.shape[1] + (2*this.padding) - this.poolSize.Item1) / this.stride) + 1;
            var y_OutputSize = (int)Math.Floor((double)(this.input.shape[2] + (2*this.padding) - this.poolSize.Item2) / this.stride) + 1;
            var output = np.zeros(this.input.shape[0], x_OutputSize, y_OutputSize);
            var input_with_pad = np.copy(this.inp_with_pad);
            var max_pool_index = np.zeros();

            foreach (var x in Utils.Range(this.input.shape[0]))
            {
                //var filter = np.array(this.input[x], copy: true);

                foreach (var i in Utils.Range(x_OutputSize))
                {
                    foreach (var j in Utils.Range(y_OutputSize))
                    {
                        var max = input_with_pad[x][i * this.stride][j * this.stride];

                        foreach (var k in Utils.Range(this.poolSize.Item1))
                        {
                            foreach (var l in Utils.Range(this.poolSize.Item2))
                            {
                                var value = input_with_pad[x][i * this.stride +k][j * this.stride + l];

                                if ((int)max <= (int)value)
                                {
                                    max = value;
                                    max_pool_index = np.array(new int[] { x, (i * this.stride + k), (j * this.stride + l) });
                                }
                            }

                        }
                        this.maxPool_index.append(max_pool_index);
                        output[x][i][j] = max;
                    }
                }
            }

            this.output = output;
            return output;
        }

        public NDarray backward(NDarray dz_input) {
            NDarray input = np.zeros((this.inp_with_pad.shape));
            NDarray dPoolImage = dz_input.flatten();
            int dpool_index = 0;

            foreach (var x in Utils.Range(dz_input.shape[0])) {
                dPoolImage = (NDarray)0;
                foreach (var y in Utils.nEnumerate(this.maxPool_index)) {
                    input[y[0]][y[1]][y[2]] = dPoolImage[dpool_index];
                    dpool_index++;
                }
            }

            if (this.padding > 0) {
                input = this.unpad(input);
            }

            return input;
        }
    }
}
