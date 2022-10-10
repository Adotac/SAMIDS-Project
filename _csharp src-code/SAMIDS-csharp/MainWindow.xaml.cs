using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

using System.IO;
using System.Text;

using SAMIDS_csharp.Implementation;

namespace SAMIDS_csharp
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private ARCHITECTURE arch = new ARCHITECTURE();
        private CNN cnn;

        public MainWindow()
        {
            InitializeComponent();
            
        }

        // Test function for CNN don't delete!!
        void test() {
            int num_vehicles = 5; // temporary for last output size, should be pass value in initialization

            var archs = new List<ARCHITECTURE>
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
                new ARCHITECTURE(){layer_type="dense", input_size=27, output_size=num_vehicles, activation="softmax"},
            };
        }
        private void Button_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
