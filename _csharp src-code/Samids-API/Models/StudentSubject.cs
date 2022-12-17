namespace Samids_API.Models
{
    public class StudentSubject
    {
        public int Id { get; set; }
        public string Year { get; set; } = string.Empty;
        public Student Student { get; set; }
        public int StudentID { get; set; }
        public Subject Subject { get; set; }
        public int SubjectID { get; set; }
    }
}
