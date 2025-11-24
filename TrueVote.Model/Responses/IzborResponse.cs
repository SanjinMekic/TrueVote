using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class IzborResponse
    {
        public int Id { get; set; }

        public int TipIzboraId { get; set; }

        public DateTime DatumPocetka { get; set; }

        public DateTime DatumKraja { get; set; }

        public string Status { get; set; }

        public TipIzboraResponse TipIzbora { get; set; }
    }
}
