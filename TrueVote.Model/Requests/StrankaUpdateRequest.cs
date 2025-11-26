using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class StrankaUpdateRequest
    {
        public string? Naziv { get; set; }

        public string? Opis { get; set; }

        public DateTime? DatumOsnivanja { get; set; }

        public int? BrojClanova { get; set; }

        public string? Sjediste { get; set; }

        public string? WebUrl { get; set; }

        public string? LogoBase64 { get; set; }
    }
}
