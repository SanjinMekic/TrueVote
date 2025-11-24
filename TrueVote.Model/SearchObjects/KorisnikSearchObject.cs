using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.SearchObjects
{
    public class KorisnikSearchObject : BaseSearchObject
    {
        public string? Ime { get; set; }
        public string? Prezime { get; set; }
        public string? Email { get; set; }
        public string? KorisnickoIme { get; set; }
        public string? OpstinaNaziv { get; set; }
    }
}
