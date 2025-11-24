using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class PitanjeUpdateRequest
    {
        public int? KategorijaId { get; set; }

        public string? PitanjeText { get; set; }

        public string? OdgovorText { get; set; }

        public DateTime? DatumKreiranja { get; set; }
    }
}
