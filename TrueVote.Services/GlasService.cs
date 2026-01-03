using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Exceptions;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services.Database;

namespace TrueVote.Services
{
    public class GlasService : BaseCRUDService<GlasResponse, GlasSearchObject, Glas, GlasInsertRequest, GlasUpdateRequest>, IGlasService
    {
        public GlasService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override void BeforeInsert(GlasInsertRequest request, Glas entity)
        {
            var korisnik = Context.Korisniks
                .Include(x => x.Opstina)
                .FirstOrDefault(x => x.Id == request.KorisnikId);

            if (korisnik == null)
                throw new UserException("Korisnik ne postoji.");

            var kandidat = Context.Kandidats
                .Include(x => x.Izbor)
                .ThenInclude(x => x.TipIzbora)
                .FirstOrDefault(x => x.Id == request.KandidatId);

            if (kandidat == null)
                throw new UserException("Kandidat ne postoji.");

            var izbor = kandidat.Izbor;
            var tip = izbor.TipIzbora;

            if (tip.OpstinaId != korisnik.OpstinaId)
                throw new UserException("Ne možete glasati za izbor koji nije u vašoj općini.");

            if (izbor.Status == "Završen")
                throw new UserException("Ovaj izbor trenutno nije aktivan.");

            //var sada = DateTime.Now;
            //if (sada < izbor.DatumPocetka || sada > izbor.DatumKraja)
            //    throw new UserException("Glasanje nije moguće. Izbor nije trenutno u toku.");

            var korisnikoviGlasovi = Context.Glas
                .Include(x => x.Kandidat)
                .Where(x => x.KorisnikId == request.KorisnikId &&
                            x.Kandidat.IzborId == izbor.Id)
                .Count();

            if (!tip.DozvoljenoViseGlasova)
            {
                if (korisnikoviGlasovi >= 1)
                    throw new UserException("Već ste glasali na ovom izboru.");
            }
            else
            {
                if (tip.MaxBrojGlasova.HasValue &&
                    korisnikoviGlasovi >= tip.MaxBrojGlasova.Value)
                {
                    throw new UserException(
                        $"Prema pravilima ovog izbora, maksimalno možete dati {tip.MaxBrojGlasova} glasova.");
                }
            }

            entity.VrijemeGlasanja = DateTime.Now;
        }

        public async Task<int> GetUkupanBrojGlasovaZaKandidataAsync(int kandidatId)
        {
            var kandidat = await Context.Kandidats.FindAsync(kandidatId);
            if (kandidat == null)
                throw new UserException("Kandidat ne postoji.");

            var brojGlasova = await Context.Glas
                .Where(g => g.KandidatId == kandidatId && g.Obrisan == false)
                .CountAsync();

            return brojGlasova;
        }

        public async Task<bool> JeLiKorisnikZavrsioGlasanjeAsync(int izborId, int korisnikId)
        {
            var korisnik = await Context.Korisniks
        .FirstOrDefaultAsync(k => k.Id == korisnikId && k.Obrisan == false);

            if (korisnik == null)
                throw new UserException("Korisnik ne postoji.");

            var izbor = await Context.Izbors
                .FirstOrDefaultAsync(i => i.Id == izborId);

            if (izbor == null)
                throw new UserException("Izbor ne postoji.");

            var brojGlasova = await Context.Glas
                .Include(g => g.Kandidat)
                .Where(g =>
                    g.KorisnikId == korisnikId &&
                    g.Kandidat.IzborId == izborId &&
                    g.Obrisan == false)
                .CountAsync();

            return brojGlasova >= 1;
        }

        public async Task<List<GlasResponse>>
    GetGlasoviZaKorisnikaSaIzborimaAsync(int korisnikId)
        {
            var korisnik = await Context.Korisniks
                .FirstOrDefaultAsync(k => k.Id == korisnikId && k.Obrisan == false);

            if (korisnik == null)
                throw new UserException("Korisnik ne postoji.");

            var glasovi = await Context.Glas
    .Include(g => g.Kandidat)
        .ThenInclude(k => k.Stranka)
    .Include(g => g.Kandidat)
        .ThenInclude(k => k.Izbor)
            .ThenInclude(i => i.TipIzbora)
                .ThenInclude(t => t.Opstina)
                .ThenInclude(o => o.Grad)
                .ThenInclude(g => g.Drzava)
    .Where(g =>
        g.KorisnikId == korisnikId &&
        g.Obrisan == false)
    .OrderByDescending(g => g.VrijemeGlasanja)
    .ToListAsync();

            var result = Mapper.Map<List<GlasResponse>>(glasovi);

            foreach (var glas in result)
            {
                var entity = glasovi.First(g => g.Id == glas.Id);

                if (entity.Kandidat != null)
                {
                    glas.Kandidat.Slika = entity.Kandidat.Slika != null
                        ? Convert.ToBase64String(entity.Kandidat.Slika)
                        : null;
                }
            }

            return result;
        }
    }
}
