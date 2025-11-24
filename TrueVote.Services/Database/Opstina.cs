using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Opstina
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public int GradId { get; set; }

    public virtual Grad Grad { get; set; } = null!;

    public virtual ICollection<Korisnik> Korisniks { get; set; } = new List<Korisnik>();

    public virtual ICollection<TipIzbora> TipIzboras { get; set; } = new List<TipIzbora>();
}
