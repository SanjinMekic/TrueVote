using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class KorisnikUpdateRequest
    {
        public string? Ime { get; set; }

        public string? Prezime { get; set; }

        public string? Email { get; set; }

        public string? KorisnickoIme { get; set; }

        public string? Lozinka { get; set; }

        public string? LozinkaPotvrda { get; set; }

        public int? UlogaId { get; set; }

        public int? OpstinaId { get; set; }

        public string? SlikaBase64 { get; set; }

        public string? Pin { get; set; }
    }
}
