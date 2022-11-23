using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Numpy;
using OpenCvSharp;

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
        (bool, string) face_label = (false, "");

        private NDarray obj;
        
        CNN(
            string train_data_loc,
            string test_data_loc,
            string saved_model_loc,
            string model_name,
            string model, 
            string? face_label
            ) { 
            
            this.architecture = new List<ARCHITECTURE>(); // check for empty list in init
            this.train_data_loc = train_data_loc;
            this.test_data_loc = test_data_loc;
            this.saved_model_loc = saved_model_loc;
            this.model_name = model_name + ".pckl";
            if (face_label != null) {
                this.face_label = (true, face_label);
            }
            // later bool variables

            //if (this.face_label.Item1 == false) { 
            //    this.obj = 
            //}
            
        }

        private List<object> initObjectlayer() {
            List<object> objectLayer = new List<object>();
            string currentLayer;
            
            for (int i = 0; i < this.architecture.Count; i++) {
                currentLayer = this.architecture[i].layer_type;

                if (currentLayer == "conv")
                {
                    var obj = new ConvLayer(this.architecture[i].filter_size, this.architecture[i].kernel_size,
                        this.architecture[i].stride, this.architecture[i].padding, this.architecture[i].activation);
                }
                else if (currentLayer == "max_pool") {
                    var obj = new MaxpoolLayer(this.architecture[i].pool_size, this.architecture[i].padding, this.architecture[i].stride);
                }
                else if (currentLayer == "flatten") {
                    var obj = "flatten";
                }
                else if (currentLayer == "dense") {
                    var obj = new DenseLayer(this.architecture[i].input_size, this.architecture[i].output_size, this.architecture[i].activation);
                }

                objectLayer.Append(obj);

            }

            return objectLayer;
        }

        //private String label_predict(double n) {
        //    return this.face_label.Item2[n];
        //}

        // find out first the data type of image using eiither opencv or emgu or other libraries
        //private NDarray labels(OpenCvSharp.Mat img) { // one_hot_labels // erase comment later
        //    //Cv2.ImRead()
        //    //Cv2.Resize(img, 0, img.shape);
        //    //Cv2.CreateFrameSource_Video
        //}

        public String train(int epochs = 1) {
            // char char unya nani dre lmao

            return "Model Training Complete!";
        }
    }


}
