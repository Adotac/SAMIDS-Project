﻿using System;
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
           // Camera_test NewWindowB = new Camera_test();
           // NewWindowB.Show();

            InitializeComponent();
        }

        // Test function for CNN don't delete!!
        void test() {
            int num_vehicles = 5; // temporary for last output size, should be pass value in initialization

            
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
