using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class TipIzboraUpdateRequest
    {
        public string? Naziv { get; set; }

        public bool? DozvoljenoViseGlasova { get; set; }

        public int? MaxBrojGlasova { get; set; }

        public int? OpstinaId { get; set; }
    }
}
