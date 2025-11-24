using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Izbor
{
    public int Id { get; set; }

    public int TipIzboraId { get; set; }

    public DateTime DatumPocetka { get; set; }

    public DateTime DatumKraja { get; set; }

    public string Status { get; set; } = null!;

    public virtual ICollection<Kandidat> Kandidats { get; set; } = new List<Kandidat>();

    public virtual TipIzbora TipIzbora { get; set; } = null!;
}
