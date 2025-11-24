using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Stranka
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public byte[]? Logo { get; set; }

    public virtual ICollection<Kandidat> Kandidats { get; set; } = new List<Kandidat>();
}
