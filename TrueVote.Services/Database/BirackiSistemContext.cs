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
            entity.HasKey(e => e.Id).HasName("PK__Drzava__3214EC07D3A348C0");

            entity.ToTable("Drzava");

            entity.Property(e => e.Naziv).HasMaxLength(100);
        });

        modelBuilder.Entity<Glas>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Glas__3214EC0761FC752D");

            entity.Property(e => e.VrijemeGlasanja).HasColumnType("datetime");

            entity.HasOne(d => d.Kandidat).WithMany(p => p.Glas)
                .HasForeignKey(d => d.KandidatId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Glas__KandidatId__5BE2A6F2");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Glas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Glas__KorisnikId__5AEE82B9");
        });

        modelBuilder.Entity<Grad>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Grad__3214EC0725F67DAB");

            entity.ToTable("Grad");

            entity.Property(e => e.Naziv).HasMaxLength(100);

            entity.HasOne(d => d.Drzava).WithMany(p => p.Grads)
                .HasForeignKey(d => d.DrzavaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Grad__DrzavaId__3B75D760");
        });

        modelBuilder.Entity<Izbor>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Izbor__3214EC07E7122481");

            entity.ToTable("Izbor");

            entity.Property(e => e.DatumKraja).HasColumnType("datetime");
            entity.Property(e => e.DatumPocetka).HasColumnType("datetime");
            entity.Property(e => e.Status).HasMaxLength(20);

            entity.HasOne(d => d.TipIzbora).WithMany(p => p.Izbors)
                .HasForeignKey(d => d.TipIzboraId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Izbor__TipIzbora__52593CB8");
        });

        modelBuilder.Entity<Kandidat>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Kandidat__3214EC077A586614");

            entity.ToTable("Kandidat");

            entity.Property(e => e.Ime).HasMaxLength(100);
            entity.Property(e => e.Prezime).HasMaxLength(100);

            entity.HasOne(d => d.Izbor).WithMany(p => p.Kandidats)
                .HasForeignKey(d => d.IzborId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Kandidat__IzborI__571DF1D5");

            entity.HasOne(d => d.Stranka).WithMany(p => p.Kandidats)
                .HasForeignKey(d => d.StrankaId)
                .HasConstraintName("FK__Kandidat__Strank__5629CD9C");
        });

        modelBuilder.Entity<Kategorija>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Kategori__3214EC07806C5647");

            entity.ToTable("Kategorija");

            entity.Property(e => e.Naziv).HasMaxLength(100);
            entity.Property(e => e.Opis).HasMaxLength(500);
        });

        modelBuilder.Entity<Korisnik>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Korisnik__3214EC07B017AC1D");

            entity.ToTable("Korisnik");

            entity.HasIndex(e => e.KorisnickoIme, "UQ__Korisnik__992E6F92CF86A28D").IsUnique();

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
                .HasConstraintName("FK__Korisnik__Opstin__47DBAE45");

            entity.HasOne(d => d.Uloga).WithMany(p => p.Korisniks)
                .HasForeignKey(d => d.UlogaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Korisnik__UlogaI__46E78A0C");
        });

        modelBuilder.Entity<Opstina>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Opstina__3214EC070BB467F5");

            entity.ToTable("Opstina");

            entity.Property(e => e.Naziv).HasMaxLength(100);

            entity.HasOne(d => d.Grad).WithMany(p => p.Opstinas)
                .HasForeignKey(d => d.GradId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Opstina__GradId__3F466844");
        });

        modelBuilder.Entity<Pitanje>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Pitanje__3214EC0717452671");

            entity.ToTable("Pitanje");

            entity.Property(e => e.DatumKreiranja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.PitanjeText).HasMaxLength(1000);

            entity.HasOne(d => d.Kategorija).WithMany(p => p.Pitanjes)
                .HasForeignKey(d => d.KategorijaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Pitanje__Kategor__6383C8BA");
        });

        modelBuilder.Entity<Stranka>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Stranka__3214EC07D434D0BD");

            entity.ToTable("Stranka");

            entity.Property(e => e.DatumOsnivanja).HasColumnType("date");
            entity.Property(e => e.Naziv).HasMaxLength(100);
            entity.Property(e => e.Opis).HasMaxLength(500);
            entity.Property(e => e.Sjediste).HasMaxLength(200);
            entity.Property(e => e.WebUrl).HasMaxLength(200);
        });

        modelBuilder.Entity<TipIzbora>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__TipIzbor__3214EC076193DE3C");

            entity.ToTable("TipIzbora");

            entity.Property(e => e.Naziv).HasMaxLength(100);

            entity.HasOne(d => d.Opstina).WithMany(p => p.TipIzboras)
                .HasForeignKey(d => d.OpstinaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__TipIzbora__Opsti__4E88ABD4");
        });

        modelBuilder.Entity<Uloga>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Uloga__3214EC07822282DD");

            entity.ToTable("Uloga");

            entity.Property(e => e.Naziv).HasMaxLength(50);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
