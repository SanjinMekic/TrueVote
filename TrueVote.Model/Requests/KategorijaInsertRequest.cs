using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class KategorijaInsertRequest
    {
        public string Naziv { get; set; }
        public string? Opis { get; set; }
    }
}
