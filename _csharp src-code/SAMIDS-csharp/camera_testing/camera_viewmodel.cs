using System;
using System.Collections.ObjectModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media.Imaging;
using System.Threading;
using System.ComponentModel;
using forms = System.Windows.Forms;

using AForge.Video;
using AForge.Video.DirectShow;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Win32;

namespace SAMIDS_csharp.camera_testing
{
    internal class camera_viewmodel : ObservableObject, IDisposable
    {
        Camera_test Form = Application.Current.Windows[1] as Camera_test; // to access camera test window xaml elements
        #region Private fields

        private FilterInfo _currentDevice;

        private BitmapSource _image;
        private string _ipCameraUrl;

        private bool _isDesktopSource;
        private bool _isIpCameraSource;
        private bool _isWebcamSource;
        
        private IVideoSource _videoSource;
        //private  _writer;
        private bool _recording;
        private DateTime? _firstFrameTime;

        #endregion

        #region Constructor

        public camera_viewmodel()
        {
            VideoDevices = new ObservableCollection<FilterInfo>();
            GetVideoDevices();
            IsDesktopSource = false;
            StartSourceCommand = new RelayCommand(StartCamera);
            StopSourceCommand = new RelayCommand(StopCamera);
            SaveSnapshotCommand = new RelayCommand(SaveSnapshot);
            IpCameraUrl = "";
        }

        #endregion

        #region Properties

        public ObservableCollection<FilterInfo> VideoDevices { get; set; }

        public BitmapSource Image
        {
            get { return _image; }
            set { this._image = value; }
        }

        public bool IsDesktopSource
        {
            get { return _isDesktopSource; }
            set { this._isDesktopSource = value; }
        }

        public bool IsWebcamSource
        {
            get { return _isWebcamSource; }
            set { this._isWebcamSource = value; }
        }

        public bool IsIpCameraSource
        {
            get { return _isIpCameraSource; }
            set { this._isIpCameraSource = value; }
        }

        public string IpCameraUrl
        {
            get { return _ipCameraUrl; }
            set { this._ipCameraUrl = value; }
        }

        public FilterInfo CurrentDevice
        {
            get { return _currentDevice; }
            set { 
                this._currentDevice = value;
                this.OnPropertyChanged("CurrentDevice");
            }
        }
        public ICommand StartSourceCommand { get; private set; }

        public ICommand StopSourceCommand { get; private set; }

        public ICommand SaveSnapshotCommand { get; private set; }

        #endregion

        private void GetVideoDevices()
        {
            var devices = new FilterInfoCollection(FilterCategory.VideoInputDevice);
            foreach (FilterInfo device in devices)
            {
                VideoDevices.Add(device);
            }
            if (VideoDevices.Any())
            {
                CurrentDevice = VideoDevices[0];
            }
            else
            {
                MessageBox.Show("No webcam found");
            }

        }

        private void StartCamera()
        {
            //if (IsDesktopSource)
            //{
            //    var rectangle = new Rectangle();
            //    foreach (var screen in forms.Screen.AllScreens)
            //    {
            //        rectangle = Rectangle.Union(rectangle, screen.Bounds);
            //    }
            //    _videoSource = (IVideoSource) new Accord.Video.ScreenCaptureStream(rectangle);
            //    _videoSource.NewFrame += video_NewFrame;
            //    _videoSource.Start();
            //}
            //else 
            if (IsWebcamSource)
            {
                if (CurrentDevice != null)
                {
                    _videoSource = new VideoCaptureDevice(CurrentDevice.MonikerString);
                    _videoSource.NewFrame += video_NewFrame;
                    _videoSource.Start();
                }
                else
                {
                    MessageBox.Show("Current device can't be null");
                }
            }
            else if (IsIpCameraSource)
            {
                _videoSource = new MJPEGStream(IpCameraUrl);
                _videoSource.NewFrame += video_NewFrame;
                _videoSource.Start();
            }
        }

        //private Image drawRect(Image img) {
        //    //Bitmap bmp = new Bitmap(260, 260, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
        //    Graphics gBmp = Graphics.FromImage(img);
        //    gBmp.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;

        //    // draw a green rectangle to the bitmap in memory
        //    gBmp.FillRectangle(new SolidBrush(Color.Red), 100, 50, 100, 100);

            
        //    forms.PaintEventArgs(gBmp).Graphics.DrawImage(img, new PointF(0.0F, 0.0F));

        //    gBmp.Dispose();
        //    return img;
        //}

        private void video_NewFrame(object sender, NewFrameEventArgs eventArgs)
        {
            try
            {
                //if (_recording)
                //{
                //    using (var bitmap = (Bitmap)eventArgs.Frame.Clone())
                //    {
                //        if (_firstFrameTime != null)
                //        {
                //            _writer.WriteVideoFrame(bitmap, DateTime.Now - _firstFrameTime.Value);
                //        }
                //        else
                //        {
                //            _writer.WriteVideoFrame(bitmap);
                //            _firstFrameTime = DateTime.Now;
                //        }
                //    }
                //}
                using (var bitmap = (Bitmap)eventArgs.Frame.Clone())
                {
                    
                    //var b = (Bitmap)drawRect(bitmap);
                    var bi = bitmap.BitmapToBitmapSource();
                    bi.Freeze();
                    //Application.Current.Dispatcher.Invoke(() => Image = bi);
                    Application.Current.Dispatcher.BeginInvoke(new ThreadStart(delegate { Form.cam_screen.Source = bi; Image = bi; }));
                }
            }
            catch (Exception exc)
            {
                MessageBox.Show("Error on _videoSource_NewFrame:\n" + exc.Message, "Error", MessageBoxButton.OK,
                    MessageBoxImage.Error);
                StopCamera();
            }
        }

        private void StopCamera()
        {
            if (_videoSource != null && _videoSource.IsRunning)
            {
                _videoSource.SignalToStop();
                _videoSource.NewFrame -= video_NewFrame;
            }
            Image = null;
        }

        private void SaveSnapshot()
        {
            var encoder = new PngBitmapEncoder();
            encoder.Frames.Add(BitmapFrame.Create(Image)); // try catch error here

            var dialog = new SaveFileDialog();
            dialog.FileName = "Snapshot1";
            dialog.DefaultExt = ".png";
            var dialogresult = dialog.ShowDialog();
            if (dialogresult != true)
            {
                return;
            }

            using (var filestream = new FileStream(dialog.FileName, FileMode.Create))
            {
                encoder.Save(filestream);
            }
        }

        public void Dispose()
        {
            if (_videoSource != null && _videoSource.IsRunning)
            {
                _videoSource.SignalToStop();
            }
            //_writer?.Dispose();
        }

        #region INotifyPropertyChanged members

        public event PropertyChangedEventHandler PropertyChanged;

        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChangedEventHandler handler = this.PropertyChanged;
            if (handler != null)
            {
                var e = new PropertyChangedEventArgs(propertyName);
                handler(this, e);
            }
        }

        #endregion
    }
}