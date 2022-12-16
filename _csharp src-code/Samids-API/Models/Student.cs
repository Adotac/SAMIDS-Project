namespace Samids_API.Models
{
    public class Student
    {
        public int StudentID { get; set; }
        public string LastName { get; set;} = string.Empty;
        public string FirstName { get; set;} = string.Empty;
        public string Course { get; set;} = string.Empty; 
        public Year Year { get; set;}
    }
     
    public enum Year
        {
            First,
            Second,
            Third,
            Fourth
        }
}
