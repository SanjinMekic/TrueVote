using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace TrueVote.Services.Database;

public partial class BirackiSistemContext : DbContext
{
    public BirackiSistemContext()
    {
    }

    public BirackiSistemContext(DbContextOptions<BirackiSistemContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Drzava> Drzavas { get; set; }

    public virtual DbSet<Glas> Glas { get; set; }

    public virtual DbSet<Grad> Grads { get; set; }

    public virtual DbSet<Izbor> Izbors { get; set; }

    public virtual DbSet<Kandidat> Kandidats { get; set; }

    public virtual DbSet<Kategorija> Kategorijas { get; set; }

    public virtual DbSet<Korisnik> Korisniks { get; set; }

    public virtual DbSet<Opstina> Opstinas { get; set; }

    public virtual DbSet<Pitanje> Pitanjes { get; set; }

    public virtual DbSet<Stranka> Strankas { get; set; }

    public virtual DbSet<TipIzbora> TipIzboras { get; set; }

    public virtual DbSet<Uloga> Ulogas { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=localhost; Database=BirackiSistem; Integrated Security=True; TrustServerCertificate=True;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Drzava>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Drzava__3214EC07FBEC9316");

            entity.ToTable("Drzava");

            entity.Property(e => e.Naziv).HasMaxLength(100);
        });

        modelBuilder.Entity<Glas>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Glas__3214EC07395AAAC3");

            entity.Property(e => e.VrijemeGlasanja).HasColumnType("datetime");

            entity.HasOne(d => d.Kandidat).WithMany(p => p.Glas)
                .HasForeignKey(d => d.KandidatId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Glas__KandidatId__52593CB8");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Glas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Glas__KorisnikId__5165187F");
        });

        modelBuilder.Entity<Grad>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Grad__3214EC0707C94DCE");

            entity.ToTable("Grad");

            entity.Property(e => e.Naziv).HasMaxLength(100);

            entity.HasOne(d => d.Drzava).WithMany(p => p.Grads)
                .HasForeignKey(d => d.DrzavaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Grad__DrzavaId__398D8EEE");
        });

        modelBuilder.Entity<Izbor>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Izbor__3214EC0726C6E06A");

            entity.ToTable("Izbor");

            entity.Property(e => e.DatumKraja).HasColumnType("datetime");
            entity.Property(e => e.DatumPocetka).HasColumnType("datetime");
            entity.Property(e => e.Status).HasMaxLength(20);

            entity.HasOne(d => d.TipIzbora).WithMany(p => p.Izbors)
                .HasForeignKey(d => d.TipIzboraId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Izbor__TipIzbora__4AB81AF0");
        });

        modelBuilder.Entity<Kandidat>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Kandidat__3214EC07C590DCBE");

            entity.ToTable("Kandidat");

            entity.Property(e => e.Ime).HasMaxLength(100);
            entity.Property(e => e.Prezime).HasMaxLength(100);

            entity.HasOne(d => d.Izbor).WithMany(p => p.Kandidats)
                .HasForeignKey(d => d.IzborId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Kandidat__IzborI__4E88ABD4");

            entity.HasOne(d => d.Stranka).WithMany(p => p.Kandidats)
                .HasForeignKey(d => d.StrankaId)
                .HasConstraintName("FK__Kandidat__Strank__4D94879B");
        });

        modelBuilder.Entity<Kategorija>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Kategori__3214EC0733E57331");

            entity.ToTable("Kategorija");

            entity.Property(e => e.Naziv).HasMaxLength(100);
            entity.Property(e => e.Opis).HasMaxLength(500);
        });

        modelBuilder.Entity<Korisnik>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Korisnik__3214EC073E29F501");

            entity.ToTable("Korisnik");

            entity.HasIndex(e => e.KorisnickoIme, "UQ__Korisnik__992E6F92C6242163").IsUnique();

            entity.Property(e => e.Email).HasMaxLength(200);
            entity.Property(e => e.Ime).HasMaxLength(100);
            entity.Property(e => e.KorisnickoIme).HasMaxLength(100);
            entity.Property(e => e.PasswordHash).HasMaxLength(128);
            entity.Property(e => e.PasswordSalt).HasMaxLength(128);
            entity.Property(e => e.Pin)
                .HasMaxLength(10)
                .HasColumnName("PIN");
            entity.Property(e => e.Prezime).HasMaxLength(100);

            entity.HasOne(d => d.Opstina).WithMany(p => p.Korisniks)
                .HasForeignKey(d => d.OpstinaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Korisnik__Opstin__4316F928");

            entity.HasOne(d => d.Uloga).WithMany(p => p.Korisniks)
                .HasForeignKey(d => d.UlogaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Korisnik__UlogaI__4222D4EF");
        });

        modelBuilder.Entity<Opstina>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Opstina__3214EC0759A3E8C5");

            entity.ToTable("Opstina");

            entity.Property(e => e.Naziv).HasMaxLength(100);

            entity.HasOne(d => d.Grad).WithMany(p => p.Opstinas)
                .HasForeignKey(d => d.GradId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Opstina__GradId__3C69FB99");
        });

        modelBuilder.Entity<Pitanje>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Pitanje__3214EC079B39CC50");

            entity.ToTable("Pitanje");

            entity.Property(e => e.DatumKreiranja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.PitanjeText).HasMaxLength(1000);

            entity.HasOne(d => d.Kategorija).WithMany(p => p.Pitanjes)
                .HasForeignKey(d => d.KategorijaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Pitanje__Kategor__5812160E");
        });

        modelBuilder.Entity<Stranka>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Stranka__3214EC07A2FA5291");

            entity.ToTable("Stranka");

            entity.Property(e => e.Naziv).HasMaxLength(100);
        });

        modelBuilder.Entity<TipIzbora>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__TipIzbor__3214EC07DD2253C5");

            entity.ToTable("TipIzbora");

            entity.Property(e => e.Naziv).HasMaxLength(100);

            entity.HasOne(d => d.Opstina).WithMany(p => p.TipIzboras)
                .HasForeignKey(d => d.OpstinaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__TipIzbora__Opsti__47DBAE45");
        });

        modelBuilder.Entity<Uloga>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Uloga__3214EC0759E1E0C9");

            entity.ToTable("Uloga");

            entity.Property(e => e.Naziv).HasMaxLength(50);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
