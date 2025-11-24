using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.SearchObjects
{
    public class KandidatSearchObject : BaseSearchObject
    {
        public string? Ime { get; set; }
        public string? Prezime { get; set; }

        public string? StrankaNaziv { get; set; }
        public int? IzborId { get; set; }
    }
}
