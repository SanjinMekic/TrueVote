using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Drzava
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public bool Obrisan { get; set; }

    public virtual ICollection<Grad> Grads { get; set; } = new List<Grad>();
}
