using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Glas
{
    public int Id { get; set; }

    public int KorisnikId { get; set; }

    public int KandidatId { get; set; }

    public DateTime VrijemeGlasanja { get; set; }

    public bool Obrisan { get; set; }

    public virtual Kandidat Kandidat { get; set; } = null!;

    public virtual Korisnik Korisnik { get; set; } = null!;
}
