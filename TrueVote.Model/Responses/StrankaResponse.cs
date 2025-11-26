using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class StrankaResponse
    {
        public int Id { get; set; }

        public string Naziv { get; set; }

        public string? Opis { get; set; }

        public DateTime? DatumOsnivanja { get; set; }

        public int? BrojClanova { get; set; }

        public string? Sjediste { get; set; }

        public string? WebUrl { get; set; }

        public string? Logo { get; set; }
    }
}
