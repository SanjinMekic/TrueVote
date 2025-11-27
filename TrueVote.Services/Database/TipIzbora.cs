using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class TipIzbora
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public bool DozvoljenoViseGlasova { get; set; }

    public int? MaxBrojGlasova { get; set; }

    public int OpstinaId { get; set; }

    public bool Obrisan { get; set; }

    public virtual ICollection<Izbor> Izbors { get; set; } = new List<Izbor>();

    public virtual Opstina Opstina { get; set; } = null!;
}
