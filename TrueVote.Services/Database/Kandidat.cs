using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Kandidat
{
    public int Id { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public int? StrankaId { get; set; }

    public int IzborId { get; set; }

    public byte[]? Slika { get; set; }

    public virtual ICollection<Glas> Glas { get; set; } = new List<Glas>();

    public virtual Izbor Izbor { get; set; } = null!;

    public virtual Stranka? Stranka { get; set; }
}
