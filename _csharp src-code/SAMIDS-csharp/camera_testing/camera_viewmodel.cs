using System;
using System.Collections.ObjectModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using forms = System.Windows.Forms;

using Nager.VideoStream;
using AForge.Video;
using AForge.Video.DirectShow;
//using GalaSoft.MvvmLight;
//using GalaSoft.MvvmLight.CommandWpf;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Win32;

namespace SAMIDS_csharp.camera_testing
{
    internal class camera_viewmodel : ObservableObject, IDisposable
    {
        #region Private fields

        private FilterInfo _currentDevice;

        private BitmapImage _image;
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

        public BitmapImage Image
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
            set { this._currentDevice = value; }
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
                    var bi = bitmap.ToBitmapImage();
                    bi.Freeze();
                    Dispatcher.CurrentDispatcher.Invoke(() => Image = bi);
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
            var dialog = new SaveFileDialog();
            dialog.FileName = "Snapshot1";
            dialog.DefaultExt = ".png";
            var dialogresult = dialog.ShowDialog();
            if (dialogresult != true)
            {
                return;
            }
            var encoder = new PngBitmapEncoder();
            encoder.Frames.Add(BitmapFrame.Create(Image));
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
    }
}