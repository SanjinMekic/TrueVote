using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class KorisnikResponse
    {
        public int Id { get; set; }

        public string Ime { get; set; }

        public string Prezime { get; set; }

        public string Email { get; set; }

        public string KorisnickoIme { get; set; }

        public int UlogaId { get; set; }

        public int OpstinaId { get; set; }

        public string Slika { get; set; }

        public string Pin { get; set; }

        public OpstinaResponse Opstina { get; set; }

        public UlogaResponse Uloga { get; set; }
    }
}
