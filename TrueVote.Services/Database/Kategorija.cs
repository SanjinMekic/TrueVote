using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Kategorija
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public string? Opis { get; set; }

    public bool Obrisan { get; set; }

    public virtual ICollection<Pitanje> Pitanjes { get; set; } = new List<Pitanje>();
}
