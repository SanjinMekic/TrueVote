using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class GlasUpdateRequest
    {
        public int? KorisnikId { get; set; }
        public int? KandidatId { get; set; }
        public DateTime? VrijemeGlasanja { get; set; }
    }
}
