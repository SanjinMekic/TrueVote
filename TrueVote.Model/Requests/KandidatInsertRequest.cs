using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class KandidatInsertRequest
    {
        public string Ime { get; set; }
        public string Prezime { get; set; }
        public int? StrankaId { get; set; }
        public int IzborId { get; set; }
        public string? Slika { get; set; }
    }
}
