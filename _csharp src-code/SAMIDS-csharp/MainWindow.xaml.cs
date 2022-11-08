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
using System.Diagnostics;
using System.IO;
using System.Text;

using Numpy;
using ns = NumSharp;

using SAMIDS_csharp.Implementation;
using SAMIDS_csharp.camera_testing;


namespace SAMIDS_csharp
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {

        public MainWindow()
        {
            /*          
                Camera_test NewWindowB = new Camera_test();
                NewWindowB.Show();
            */

            InitializeComponent();
            test();
        }

        // Test function for CNN don't delete!!
        void test() {
            NDarray temp1 = np.array(new double[,,] { 
                { { 1, 2 }, { 6, 9 } }, 
                { { 4, 4 }, { 5,5} } 
            } 
            );

            temp1.DisplayNDarray();
            temp1.DisplayNDarrayData();

            var temp2 = 0;
            temp2 += (int)(temp1[1][1][1] + temp1[0][0][0]);
            Debug.WriteLine($">> Test::: {temp2}:");

            // debug helper util
            //foreach (var i in temp1.nEnumerate()) {
            //    //Debug.WriteLine(i);
            //    foreach (var j in i.nEnumerate()) {
            //        Debug.WriteLine(j);
            //    }
            //}

            // Debug helper util with zero ndarray
            //foreach (var i in np.zeros().nEnumerate()) {
            //    Debug.WriteLine(i);
            //}

        }
        private void Button_Click(object sender, RoutedEventArgs e)
        {
            AttendanceScreen attendanceScreen = new AttendanceScreen();
            // this.Visibility = Visibility.Hidden;
            this.Close();
            attendanceScreen.Show();
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {

        }
    }
}
