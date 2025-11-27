using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Grad
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public int DrzavaId { get; set; }

    public bool Obrisan { get; set; }

    public virtual Drzava Drzava { get; set; } = null!;

    public virtual ICollection<Opstina> Opstinas { get; set; } = new List<Opstina>();
}
