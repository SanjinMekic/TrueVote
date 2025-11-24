using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class KategorijaResponse
    {
        public int Id { get; set; }

        public string Naziv { get; set; } = null!;

        public string? Opis { get; set; }
    }
}
