using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;

using Numpy;

namespace SAMIDS_csharp.Implementation
{
    internal interface Layers
    {
        /// To group Conv Layer, DenseLayer, and Max pooling layer
        /// 
        public static void DisplayNDarray(NDarray nDarray, string name = "")
        {
            Debug.WriteLine($">> DisplayDetails {name}:");
            Debug.WriteLine($"size {nDarray.size} shape {nDarray.shape} dims {nDarray.ndim}");
            Debug.WriteLine($"mean {nDarray.mean()} std {nDarray.std()} min {nDarray.min()} max {nDarray.max()}");
        }
        public static void DisplayNDarrayData<TElementType>(NDarray nDarray)
        {
            Debug.WriteLine($"[{String.Join(", ", nDarray.GetData<TElementType>())}]");
        } // example = DisplayNDarrayData<int>(nDimArray);
    }

    internal class ConvLayer: Layers{
        private int filter_length;
        private int stride;
        private Tuple<int, int> kernel_size;
        private int padding;
        private string activation;
        private 

        public ConvLayer(
            int filter_length,
            int kernel_size,
            int stride = 1,
            int padding = 1,
            string activation = "relu"
            ) {

            this.filter_length = filter_length;
            this.kernel_size = Tuple.Create(kernel_size, kernel_size);
            this.stride = stride;
            this.padding = padding;
            this.activation = activation;
        }

        public NDarray setInput() { 
        
        }
    }
}
