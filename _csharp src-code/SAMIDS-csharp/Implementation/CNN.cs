using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Numpy;

namespace SAMIDS_csharp.Implementation
{
    internal class ARCHITECTURE {
    /// C# 6.0 above for inline auto value
        public string layer_type { get; set;}
        public string activation { get; set; }
        public int kernel_size { get; set; } = 0;
        public int filter_size { get; set; } = 0;
        public int stride { get; set; } = 0;
        public int padding { get; set; } = 0;
        public int pool_size { get; set; } = 0;
        public int input_size { get; set; } = 0;
        public int output_size { get; set; } = 0;
    }
    public class CNN
    {
        private List<ARCHITECTURE> architecture;
        private string train_data_loc;
        private string test_data_loc;
        private string saved_model_loc;
        private string model_name;

        public CNN(
            string train_data_loc,
            string test_data_loc,
            string saved_model_loc,
            string model_name,
            string model, 
            string face_label
            ) { 
            
            this.architecture = new List<ARCHITECTURE>(); // check for empty list in init
            this.train_data_loc = train_data_loc;
            this.test_data_loc = test_data_loc;
            this.saved_model_loc = saved_model_loc;
            this.model_name = model_name;
            // later bool variables
            
        }

        
        private NDarray labels() { // one_hot_labels // erase comment later
        
        }
    }


}
