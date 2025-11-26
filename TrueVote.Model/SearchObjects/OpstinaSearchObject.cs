using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.SearchObjects
{
    public class OpstinaSearchObject : BaseSearchObject
    {
        public string? Naziv { get; set; }
        public string? GradNaziv { get; set; }
        public string? DrzavaNaziv { get; set; }
    }
}
