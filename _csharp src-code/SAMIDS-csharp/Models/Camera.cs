using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media.Imaging;

namespace SAMIDS_csharp.Models
{
    internal class Camera
    {
        private String camera_name;
        private int camera_id;
        private String assigned_area;
        private String cam_source; //Camera source - TBD - Unknown Data Type

        public string CameraName
        {
            get { return camera_name; }
            set { camera_name = value; }
        }
        public int CameraId
        {
            get { return camera_id; }
            set { camera_id = value; }
        }

        public String Area
        {
            get { return assigned_area; }
            set { assigned_area = value; }
        }

        //TBD - Camera source - String not final
        public String  CameraSource
        {
            get { return cam_source; }
            set { cam_source = value; }
        }

        public BitmapImage getFrame()
        {
            BitmapImage frame = null;
            return frame;
        }


    }
}
