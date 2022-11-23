using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SAMIDS_csharp.Implementation
{
    internal class CNN_TrainTest
    {
        private List<ARCHITECTURE> arch = new List<ARCHITECTURE>();
        private CNN cnn;

        private string model_name;
        private string model_directory;
        private string train_directory;
        private string test_directory;
        private int num_of_faces;
        private string face_label;

        public CNN_TrainTest(
            string model_name,
            string model_directory,
            string train_directory,
            string test_directory,
            int num_of_faces,
            string face_label // change data type since its a pickle file or binary file
            )
        {
            this.train_directory = train_directory;
            this.test_directory = test_directory;
            this.model_directory = model_directory;
            this.model_name = model_name;
            this.num_of_faces = num_of_faces;
            this.face_label = face_label;
        }

        private List<ARCHITECTURE> setArchitecture() {
            List<ARCHITECTURE> archs = new List<ARCHITECTURE>
            {
                new ARCHITECTURE(){layer_type="conv", filter_size=2, kernel_size=3, stride=1, padding=1, activation="relu"},
                new ARCHITECTURE(){layer_type="max_pool", pool_size=2, stride=2, padding=0},

                new ARCHITECTURE(){layer_type="conv", filter_size=6, kernel_size=3, stride=1, padding=1, activation="relu"},
                new ARCHITECTURE(){layer_type="max_pool", pool_size=2, stride=2, padding=0},

                new ARCHITECTURE(){layer_type="conv", filter_size=8, kernel_size=3, stride=1, padding=1, activation="relu"},
                new ARCHITECTURE(){layer_type="max_pool", pool_size=2, stride=2, padding=0},

                new ARCHITECTURE(){layer_type="flatten"},

                new ARCHITECTURE(){layer_type="dense", input_size=512, output_size=256, activation="relu"},
                new ARCHITECTURE(){layer_type="dense", input_size=256, output_size=27, activation="relu"},
                new ARCHITECTURE(){layer_type="dense", input_size=27, output_size=this.num_of_faces, activation="softmax"},
            };

            return archs;
        }

        public String train(int epoch=20) {
            this.arch = this.setArchitecture();

            string model_source = this.model_directory + '\\' + this.model_name + ".pckl";

            // os path file to create model pickle
            if (!System.IO.File.Exists(model_source))
            {
                using (System.IO.FileStream fs = System.IO.File.Create(model_source))
                {

                    Byte[] info = new UTF8Encoding(true).GetBytes("GFG is a CS Portal.");
                    fs.Write(info, 0, info.Length);

                }
            }
            else
            {
                Console.WriteLine("File \"{0}\" already exists.", model_source);

            }


            var ret = cnn.train();
            return ret;
        }

    }

    
}
