using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SAMIDS_csharp.Models
{
    internal class Schedule
    {
        private String classCode;
        private DateTime timeStart;
        private DateTime timeEnd;
        private int days;

        public String ClassCode
        {
            get { return classCode; }
            set { classCode = value; }
        }
        public DateTime TimeStart
        {
            get { return timeStart; }
            set { timeStart = value; }
        }
        public DateTime TimeEnd
        {
            get { return timeEnd; }
            set { timeEnd = value; }
        }

        public int Days
        {
            get { return days; }
            set { days = value; }
        }
    }
}
