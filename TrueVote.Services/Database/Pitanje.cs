using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Pitanje
{
    public int Id { get; set; }

    public int KategorijaId { get; set; }

    public string PitanjeText { get; set; } = null!;

    public string OdgovorText { get; set; } = null!;

    public DateTime DatumKreiranja { get; set; }

    public virtual Kategorija Kategorija { get; set; } = null!;
}
