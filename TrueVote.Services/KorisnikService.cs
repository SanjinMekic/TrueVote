using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Models;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services.Database;

namespace TrueVote.Services
{
    public class KorisnikService : BaseCRUDService<KorisnikResponse, KorisnikSearchObject, Korisnik, KorisnikInsertRequest, KorisnikUpdateRequest>, IKorisnikService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        public KorisnikService(BirackiSistemContext context, IHttpContextAccessor httpContextAccessor, IMapper mapper) : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public override IQueryable<Korisnik> AddFilter(KorisnikSearchObject search, IQueryable<Korisnik> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrEmpty(search.Ime))
            {
                query = query.Where(k => k.Ime.Contains(search.Ime));
            }
            if (!string.IsNullOrEmpty(search.Prezime))
            {
                query = query.Where(k => k.Prezime.Contains(search.Prezime));
            }
            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(k => k.Email == search.Email);
            }
            if (!string.IsNullOrEmpty(search.KorisnickoIme))
            {
                query = query.Where(k => k.KorisnickoIme == search.KorisnickoIme);
            }
            if (!string.IsNullOrEmpty(search.OpstinaNaziv))
            {
                query = query.Where(k => k.Opstina.Naziv.Contains(search.OpstinaNaziv));
            }
            return query
                .Include(k => k.Opstina)
                    .ThenInclude(o => o.Grad)
                    .ThenInclude(g => g.Drzava)
                .Include(k => k.Uloga);
        }

        public override PagedResult<KorisnikResponse> GetPaged(KorisnikSearchObject search)
        {
            var pagedKorisnici = base.GetPaged(search);

            foreach (var korisnik in pagedKorisnici.ResultList)
            {
                var databaseKorisnik = Context.Set<Database.Korisnik>().Find(korisnik.Id);
                if (databaseKorisnik != null)
                {
                    korisnik.Slika = databaseKorisnik.Slika != null ? Convert.ToBase64String(databaseKorisnik.Slika) : null;
                }
            }

            return pagedKorisnici;
        }

        public override KorisnikResponse GetById(int id)
        {
            var entity = Context.Korisniks.Include(k => k.Uloga).Include(k => k.Opstina).ThenInclude(k => k.Grad).ThenInclude(k => k.Drzava).FirstOrDefault(k => k.Id == id);

            if (entity != null)
            {
                var model = Mapper.Map<KorisnikResponse>(entity);

                model.Slika = entity.Slika != null ? Convert.ToBase64String(entity.Slika) : null;

                return model;
            }
            else
            {
                return null;
            }
        }

        public override KorisnikResponse Insert(KorisnikInsertRequest request)
        {
            var entity = Mapper.Map<Database.Korisnik>(request);

            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();

            var model = Mapper.Map<KorisnikResponse>(entity);

            model.Slika = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            string plainPassword = request.Lozinka;

            return model;
        }

        public override KorisnikResponse Update(int id, KorisnikUpdateRequest request)
        {
            var set = Context.Set<Database.Korisnik>();

            var entity = set.Find(id);

            if (entity == null)
                return null;

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            Context.SaveChanges();

            var model = Mapper.Map<KorisnikResponse>(entity);

            model.Slika = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            return model;
        }

        public override void BeforeInsert(KorisnikInsertRequest request, Database.Korisnik entity)
        {
            if (request.Lozinka != request.LozinkaPotvrda)
            {
                throw new Exception("Lozinka i LozinkaPotvrda moraju biti iste!");
            }

            if (string.IsNullOrEmpty(request.Lozinka) || request.Lozinka.Length < 6)
            {
                throw new Exception("Lozinka mora imati najmanje 6 karaktera!");
            }

            if (string.IsNullOrEmpty(request.Ime) || !System.Text.RegularExpressions.Regex.IsMatch(request.Ime, @"^[A-Za-zČčĆćŠšĐđŽž]+$"))
            {
                throw new Exception("Ime mora sadržavati samo slova!");
            }

            if (string.IsNullOrEmpty(request.Prezime) || !System.Text.RegularExpressions.Regex.IsMatch(request.Prezime, @"^[A-Za-zČčĆćŠšĐđŽž]+$"))
            {
                throw new Exception("Prezime mora sadržavati samo slova!");
            }

            if (string.IsNullOrEmpty(request.Email) || !System.Text.RegularExpressions.Regex.IsMatch(request.Email, @"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"))
            {
                throw new Exception("Unesite validan email!");
            }

            if (Context.Korisniks.Any(u => u.KorisnickoIme == request.KorisnickoIme))
            {
                throw new Exception("Korisničko ime je već zauzeto!");
            }

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.LozinkaPotvrda);

            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }

                var uloga = Context.Ulogas.FirstOrDefault(u => u.Id == request.UlogaId);
                if (uloga == null)
                    throw new Exception($"Uloga sa ID {request.UlogaId} nije pronadjena");

            base.BeforeInsert(request, entity);
        }
        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);
            return Convert.ToBase64String(byteArray);
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public override void BeforeUpdate(KorisnikUpdateRequest request, Database.Korisnik entity)
        {
            if (!string.IsNullOrEmpty(request.Ime) && !System.Text.RegularExpressions.Regex.IsMatch(request.Ime, @"^[A-Za-zČčĆćŠšĐđŽž]+$"))
                throw new Exception("Ime mora sadržavati samo slova!");

            if (!string.IsNullOrEmpty(request.Prezime) && !System.Text.RegularExpressions.Regex.IsMatch(request.Prezime, @"^[A-Za-zČčĆćŠšĐđŽž]+$"))
                throw new Exception("Prezime mora sadržavati samo slova!");

            if (!string.IsNullOrEmpty(request.Email) && !System.Text.RegularExpressions.Regex.IsMatch(request.Email, @"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"))
                throw new Exception("Unesite validan email!");

            if (!string.IsNullOrEmpty(request.KorisnickoIme))
            {
                var postoji = Context.Korisniks.Any(u => u.KorisnickoIme == request.KorisnickoIme && u.Id != entity.Id);
                if (postoji)
                    throw new Exception("Korisničko ime je već zauzeto!");
            }

            if (request.Lozinka != null)
            {
                if (request.Lozinka != request.LozinkaPotvrda)
                    throw new Exception("Lozinka i LozinkaPotvrda moraju biti iste!");

                if (request.Lozinka.Length < 6)
                    throw new Exception("Lozinka mora imati najmanje 6 karaktera!");

                entity.PasswordSalt = GenerateSalt();
                entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Lozinka);
            }

            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }

            if (request.UlogaId != null)
            {
                    var uloga = Context.Ulogas.FirstOrDefault(u => u.Id == request.UlogaId);
                    if (uloga == null)
                        throw new Exception($"Uloga sa ID {request.UlogaId} nije pronađena");
            }

            base.BeforeUpdate(request, entity);
        }

        public KorisnikResponse Login(string username, string password)
        {
            var entity = Context.Korisniks.Include(x => x.Uloga).FirstOrDefault(x => x.KorisnickoIme == username);

            if (entity == null)
                return null;

            var hash = GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
                return null;

            if (entity.Obrisan == true)
                return null;

            return this.Mapper.Map<KorisnikResponse>(entity);
        }

        public int GetCurrentUserId()
        {
            var username = _httpContextAccessor.HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(username))
            {
                throw new UnauthorizedAccessException("Korisnik nije autentifikovan.");
            }

            var user = Context.Korisniks.FirstOrDefault(u => u.KorisnickoIme == username);
            if (user == null)
            {
                throw new UnauthorizedAccessException("Korisnik nije pronadjen.");
            }

            return user.Id;
        }

        public async Task<bool> ProvjeriKorisnickoIme(string korisnickoIme)
        {
            return await Context.Korisniks.AnyAsync(u => u.KorisnickoIme == korisnickoIme);
        }

        public bool CanDelete(int id)
        {
            bool imaGlasova = Context.Glas.Any(g => g.KorisnikId == id && g.Obrisan == false);

            if (imaGlasova)
                return false;

            return true;
        }

        public async Task<bool> KreirajPinAsync(int korisnikId, string pin)
        {
            // Validacija – mora biti tačno 4 cifre
            if (!System.Text.RegularExpressions.Regex.IsMatch(pin, @"^\d{4}$"))
                throw new Exception("PIN mora biti četveroznamenkasti broj.");

            var korisnik = await Context.Korisniks
                .FirstOrDefaultAsync(k => k.Id == korisnikId && k.Obrisan == false);

            if (korisnik == null)
                throw new Exception("Korisnik nije pronađen.");

            if (!string.IsNullOrEmpty(korisnik.Pin))
                throw new Exception("PIN je već kreiran za ovog korisnika.");

            korisnik.Pin = GenerateHash(korisnik.PasswordSalt, pin);

            await Context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ProvjeriPinAsync(int korisnikId, string pin)
        {
            if (!System.Text.RegularExpressions.Regex.IsMatch(pin, @"^\d{4}$"))
                return false;

            var korisnik = await Context.Korisniks
                .FirstOrDefaultAsync(k => k.Id == korisnikId && k.Obrisan == false);

            if (korisnik == null || string.IsNullOrEmpty(korisnik.Pin))
                return false;

            var hash = GenerateHash(korisnik.PasswordSalt, pin);

            return korisnik.Pin == hash;
        }

        public async Task<bool> PromijeniPinAsync(int korisnikId, string stariPin, string noviPin)
        {
            // Validacija – oba pina moraju biti 4 cifre
            if (!System.Text.RegularExpressions.Regex.IsMatch(stariPin, @"^\d{4}$") ||
                !System.Text.RegularExpressions.Regex.IsMatch(noviPin, @"^\d{4}$"))
            {
                throw new Exception("PIN mora biti četveroznamenkasti broj.");
            }

            var korisnik = await Context.Korisniks
                .FirstOrDefaultAsync(k => k.Id == korisnikId && k.Obrisan == false);

            if (korisnik == null)
                throw new Exception("Korisnik nije pronađen.");

            if (string.IsNullOrEmpty(korisnik.Pin))
                throw new Exception("Korisnik nema kreiran PIN.");

            var stariPinHash = GenerateHash(korisnik.PasswordSalt, stariPin);
            if (korisnik.Pin != stariPinHash)
                throw new Exception("Stari PIN nije ispravan.");

            korisnik.Pin = GenerateHash(korisnik.PasswordSalt, noviPin);

            await Context.SaveChangesAsync();
            return true;
        }
    }
}
