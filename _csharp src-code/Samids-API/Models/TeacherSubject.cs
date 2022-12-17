namespace Samids_API.Models
{
    public class TeacherSubject
    {
        public int ID { get; set; }
        public Teacher Teacher{ get; set; }

        public int TeacherID { get; set; }
        public Subject Subject { get; set; }
        public int SubjectID { get; set; }
    }
}
