using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Services.Database;

namespace TrueVote.Services.UserAdminSeed
{
    public class UserAdminSeed : IUserAdminSeed
    {
        private readonly BirackiSistemContext _context;
        public UserAdminSeed(BirackiSistemContext context)
        {
            _context = context;
        }
        public async Task Ucitaj()
        {
            if (!_context.Korisniks.Any(u => u.Email == "admin@gmail.com"))
            {
                var administrator = new Korisnik
                {
                    Ime = "Admin",
                    Prezime = "Admin",
                    Email = "admin@gmail.com",
                    KorisnickoIme = "admin",
                    UlogaId = 1,
                    OpstinaId = 4,
                    SistemAdministrator = true
                };

                var password = "admin";
                var salt = KorisnikService.GenerateSalt();
                var hashedPassword = KorisnikService.GenerateHash(salt, password);

                administrator.PasswordSalt = salt;
                administrator.PasswordHash = hashedPassword;

                _context.Korisniks.Add(administrator);
                await _context.SaveChangesAsync();
            }

            if (!_context.Korisniks.Any(u => u.Email == "birac@gmail.com"))
            {
                var korisnik = new Korisnik
                {
                    Ime = "Birac",
                    Prezime = "Birac",
                    Email = "birac@gmail.com",
                    KorisnickoIme = "birac",
                    UlogaId = 2,
                    OpstinaId = 4
                };

                var password = "birac";
                var salt = KorisnikService.GenerateSalt();
                var hashedPassword = KorisnikService.GenerateHash(salt, password);

                korisnik.PasswordSalt = salt;
                korisnik.PasswordHash = hashedPassword;

                _context.Korisniks.Add(korisnik);
                await _context.SaveChangesAsync();
            }

            await _context.SaveChangesAsync();
        }
    }
}
