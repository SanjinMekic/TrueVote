using System;
using System.Collections.Generic;

namespace TrueVote.Services.Database;

public partial class Korisnik
{
    public int Id { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public string? Email { get; set; }

    public string KorisnickoIme { get; set; } = null!;

    public string? PasswordSalt { get; set; }

    public string? PasswordHash { get; set; }

    public int UlogaId { get; set; }

    public int OpstinaId { get; set; }

    public byte[]? Slika { get; set; }

    public string? Pin { get; set; }

    public bool Obrisan { get; set; }

    public virtual ICollection<Glas> Glas { get; set; } = new List<Glas>();

    public virtual Opstina Opstina { get; set; } = null!;

    public virtual Uloga Uloga { get; set; } = null!;
}
