namespace Samids_API.Models
{
    public class SubjectSchedule
    {
        public int ID { get; set; }
        public Subject Subject { get; set; }
        public TimeOnly TimeStart { get; set; }
        public TimeOnly TimeEnd { get; set; }
        public Day Day { get; set; }
        public string Room { get; set; } = string.Empty;

    }
    
    public enum Day
    {
        Monday,
        Tuesday, 
        Wednesday,
        Thursday,
        Friday,
        Saturday
    }
}
