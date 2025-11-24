using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class PitanjeResponse
    {
        public int Id { get; set; }

        public int KategorijaId { get; set; }

        public string PitanjeText { get; set; }

        public string OdgovorText { get; set; }

        public DateTime DatumKreiranja { get; set; }

        public KategorijaResponse Kategorija { get; set; }
    }
}
