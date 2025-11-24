using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class GlasResponse
    {
        public int Id { get; set; }

        public int KorisnikId { get; set; }

        public int KandidatId { get; set; }

        public DateTime VrijemeGlasanja { get; set; }

        public KandidatResponse Kandidat { get; set; }

        public KorisnikResponse Korisnik { get; set; }
    }
}
