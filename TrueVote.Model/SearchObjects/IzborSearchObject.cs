using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.SearchObjects
{
    public class IzborSearchObject : BaseSearchObject
    {
        public string? Status { get; set; }
        public DateTime? DatumPocetka { get; set; }
        public DateTime? DatumKraja { get; set; }
    }
}
