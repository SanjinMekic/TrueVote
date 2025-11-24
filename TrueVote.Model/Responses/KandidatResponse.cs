using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class KandidatResponse
    {
        public int Id { get; set; }

        public string Ime { get; set; }

        public string Prezime { get; set; }

        public int StrankaId { get; set; }

        public int IzborId { get; set; }

        public byte[] Slika { get; set; }

        public IzborResponse Izbor { get; set; }

        public StrankaResponse Stranka { get; set; }
    }
}
