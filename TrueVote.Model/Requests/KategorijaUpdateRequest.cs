using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class KategorijaUpdateRequest
    {
        public string? Naziv { get; set; }
        public string? Opis { get; set; }
    }
}
