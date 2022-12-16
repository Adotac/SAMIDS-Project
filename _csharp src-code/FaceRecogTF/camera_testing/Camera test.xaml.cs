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
using System.Windows.Shapes;

namespace FaceRecogTF.camera_testing
{
    /// <summary>
    /// Interaction logic for Camera_test.xaml
    /// </summary>
    public partial class Camera_test : Window
    {
        public Camera_test()
        {
            InitializeComponent();
            this.Closing += (s, e) => (this.DataContext as IDisposable).Dispose();
        }




    }
}
