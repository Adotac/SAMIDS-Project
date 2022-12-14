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
using io = System.IO;
using System.Reflection;
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

            Camera_test NewWindowB = new Camera_test();
            NewWindowB.Show();


            InitializeComponent();
            test();
        }

        // Test function for CNN don't delete!!
        void test() {
            NDarray temp1 = np.array(new double[,,] { 
                { { 1, 2 }, { 6, 9 } }, 
                {{ 4, 4 }, { 5,5} } 
            } 
            );
            temp1[0][1][0] = (NDarray)99;

            temp1.DisplayNDarray();
            temp1.DisplayNDarrayData();

            var temp2 = 0;

            NDarray temp3 = np.pad(temp1, pad_width: np.array(new int[,] { {2,2},{2,2},{3,3} }) , "constant" );
            //temp2 += (int)(temp1[1][1][1] + temp1[0][0][0]);
            Debug.WriteLine($">> Test:::\n {np.array(temp3).shape}");
            //Debug.WriteLine($">> Test:::------------\n {(temp3[0][0][0]).GetDtype()}");

            string tempPath = io.Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\testFolder" ;
            Debug.WriteLine($">> Creating file at:::\n {tempPath}");
            /*System.IO.Directory.CreateDirectory(tempPath);
            string fileName = io.Path.GetRandomFileName();

            // This example uses a random string for the name, but you also can specify
            // a particular name.
            //string fileName = "MyNewFile.txt";

            // Use Combine again to add the file name to the path.
            tempPath = io.Path.Combine(tempPath, (fileName+".txt") );

            if (!System.IO.File.Exists(tempPath))
            {
                using (System.IO.FileStream fs = System.IO.File.Create(tempPath))
                {
                    for (byte i = 0; i < 100; i++)
                    {
                        Byte[] info = new UTF8Encoding(true).GetBytes("GFG is a CS Portal.");
                        fs.Write(info, 0, info.Length);
                    }
                }
            }
            else
            {
                Console.WriteLine("File \"{0}\" already exists.", fileName);
                return;
            }

            // Read and display the data from your file.
            try
            {
                byte[] readBuffer = System.IO.File.ReadAllBytes(tempPath);
                foreach (byte b in readBuffer)
                {
                    Console.Write(b + " ");
                }
                Console.WriteLine();
            }
            catch (System.IO.IOException e)
            {
                Console.WriteLine(e.Message);
            } */

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
