using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;

using Numpy;

namespace SAMIDS_csharp.Implementation
{
    static class Utils
    {
        public static IEnumerable<int> Range(int start, int stop, int step = 1)
        {
            if (step == 0)
                throw new ArgumentException(nameof(step));

            while (step > 0 && start < stop || step < 0 && start > stop)
            {
                // Small optimization
                //if (step > 0)
                //{
                //    while (start < stop)
                //    {
                //        yield return start;
                //        start += step;
                //    }
                //}
                //else
                //{
                //    while (start > stop)
                //    {
                //        yield return start;
                //        start += step;
                //    }
                //}

                yield return (int)start;
                start += step;
            }
        }

        public static IEnumerable<int> Range(int stop) => Range(0, stop, 1);

        public static void DisplayNDarray(this NDarray nDarray, string name = "")
        {
            Debug.WriteLine($">> DisplayDetails {name}:");
            Debug.WriteLine($"size {nDarray.size} shape {nDarray.shape} dims {nDarray.ndim}");
            Debug.WriteLine($"mean {nDarray.mean()} std {nDarray.std()} min {nDarray.min()} max {nDarray.max()}");
        }
        public static void DisplayNDarrayData(this NDarray nDarray)
        {
            //Debug.WriteLine($"[{String.Join(", ", nDarray.GetData<TElementType>())}]");
            for (int i = 0; i < nDarray.shape.Dimensions[0]; i++)
            {
                Debug.WriteLine(nDarray[i]);
            }
        } // example = DisplayNDarrayData<int>(nDimArray);

        public static IEnumerable<NDarray> nEnumerate(this NDarray nDarray)
        {
            if (nDarray.ndim == 0)
                throw new ArgumentException(nameof(nDarray) + " : " +"Empty numpy array");

            int index = 0;
            int shape1dimension = nDarray.shape.Dimensions[0];

            while (index < shape1dimension) {
                yield return nDarray[index];
                index++;
            }
        }
    }
}
