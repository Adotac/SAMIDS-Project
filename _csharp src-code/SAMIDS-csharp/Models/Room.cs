using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SAMIDS_csharp.Models
{
    internal class Room
    {
        private int room_number;
        private int assigned_camID;
        private List<object> attendance_log; //will refer from Attendance modal
        private List<object> roomSchedule; // will refer from Schedule modal

        public int RoomNumber
        {
            get { return room_number; }
            set { room_number = value; }
        }

        public int ACameraID
        {
            get { return assigned_camID;}
            set { assigned_camID = value; }
        }
        public List<object> AttendanceLog
        {
            get { return attendance_log; }
        }

        public List<object> RoomSchedule
        {
            get { return roomSchedule; }
        }

        public void assignCamera(int id)
        {
            
        }
    }
}
