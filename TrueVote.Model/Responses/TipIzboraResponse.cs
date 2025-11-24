using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class TipIzboraResponse
    {
        public int Id { get; set; }

        public string Naziv { get; set; }

        public bool DozvoljenoViseGlasova { get; set; }

        public int? MaxBrojGlasova { get; set; }

        public int OpstinaId { get; set; }

        public OpstinaResponse Opstina { get; set; }
    }
}
