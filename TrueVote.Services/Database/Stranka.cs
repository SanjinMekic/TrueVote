using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Stranka
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public string? Opis { get; set; }

    public DateTime? DatumOsnivanja { get; set; }

    public int? BrojClanova { get; set; }

    public string? Sjediste { get; set; }

    public string? WebUrl { get; set; }

    public byte[]? Logo { get; set; }

    public virtual ICollection<Kandidat> Kandidats { get; set; } = new List<Kandidat>();
}
