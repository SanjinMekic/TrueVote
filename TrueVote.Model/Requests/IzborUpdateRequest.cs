using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class IzborUpdateRequest
    {
        public int? TipIzboraId { get; set; }
        public DateTime? DatumPocetka { get; set; }
        public DateTime? DatumKraja { get; set; }
        public string? Status { get; set; }
    }
}
