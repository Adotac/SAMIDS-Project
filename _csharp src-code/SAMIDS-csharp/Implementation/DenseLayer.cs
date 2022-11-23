using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Numpy;

namespace SAMIDS_csharp.Implementation
{
    internal class DenseLayer
    {
        private int inputSize;
        private int outputSize;
        private String activation;
        private NDarray weight, bias;
        private NDarray input, output, outputActivated, diz;

        public DenseLayer(
            int inputSize,
            int outputSize,
            String activation
            ) {
            this.inputSize = inputSize;
            this.outputSize = outputSize;
            this.activation = activation;
            this.weight = np.random.randn(outputSize, inputSize) * np.sqrt(np.array(new double[] { (1/outputSize) }));
            this.bias = np.full((outputSize, 1), 0, dtype: np.@double);
            this.output = np.zeros();
            this.outputActivated = np.zeros();
            this.diz = np.zeros();
        }

        public void setInput(NDarray input) {
            this.input = input;
        }
        private NDarray relU(NDarray input) {
            return np.maximum((NDarray)0, input);
        }
        private NDarray softmax(NDarray input) {
            input -= np.max(input);
            var z = np.exp(input) / np.sum(np.exp(input));
            return z;
        }
        private NDarray backwardRelU(NDarray dz_input) {
            dz_input = np.array(dz_input, copy: true);
            var dr = np.where(this.output > 0, dz_input, (NDarray)0);
            return dr;
        }
        private NDarray backwardSoftmax(NDarray dz_input) {
            var z = this.outputActivated;
            var ds = z * (dz_input - np.sum(dz_input*z));
            return ds;
        }
        public NDarray forward() {
            NDarray actv = np.zeros();
            this.output = np.dot(this.weight, this.input) + this.bias;
            if (this.activation == "relu")
                actv = this.relU(this.input);
            else
                actv = this.softmax(this.input);

            this.outputActivated = actv;
            return this.outputActivated;
        }

        public NDarray backward(NDarray dz_input) {
            NDarray actv = np.zeros();
            if (this.activation == "relu")
                actv = this.backwardRelU(dz_input);
            else
                actv = this.backwardSoftmax(dz_input);

            dz_input = np.dot( this.weight.T, dz_input );
            return dz_input;
        }
        public (NDarray,NDarray) gradient_function(NDarray dz_input) {
            NDarray dw = np.dot(dz_input, this.input.T);
            NDarray db = np.sum(dz_input, axis: 1, keepdims: true);
            return (dw, db);
        }

    }
}
