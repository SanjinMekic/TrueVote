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
    public class IzborService : BaseCRUDService<IzborResponse, IzborSearchObject, Izbor, IzborInsetRequest, IzborUpdateRequest>, IIzborService
    {
        public IzborService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Izbor> AddFilter(IzborSearchObject search, IQueryable<Izbor> query)
        {
            // AUTOMATSKA SINHRONIZACIJA STATUSA
            SyncIzborStatus();

            query = base.AddFilter(search, query);

            if (!string.IsNullOrEmpty(search.Status))
            {
                query = query.Where(i => i.Status == search.Status);
            }
            if (search.DatumPocetka.HasValue && !search.DatumKraja.HasValue)
            {
                query = query.Where(i => i.DatumPocetka.Date >= search.DatumPocetka.Value.Date);
            }
            if (!search.DatumPocetka.HasValue && search.DatumKraja.HasValue)
            {
                query = query.Where(i => i.DatumKraja.Date <= search.DatumKraja.Value.Date);
            }
            if (search.DatumPocetka.HasValue && search.DatumKraja.HasValue)
            {
                query = query.Where(i => i.DatumPocetka.Date >= search.DatumPocetka.Value.Date && i.DatumKraja.Date <= search.DatumKraja.Value.Date);
            }
            return base.AddFilter(search, query).Include(i => i.TipIzbora)
                .ThenInclude(ti => ti.Opstina)
                .ThenInclude(o => o.Grad)
                .ThenInclude(g => g.Drzava);
        }

        private void SyncIzborStatus()
        {
            var danas = DateTime.Now.Date;

            var izbori = Context.Izbors
                .Where(i =>
                    (i.Status == "Planiran" && i.DatumPocetka.Date <= danas) ||
                    (i.Status == "U toku" && i.DatumKraja.Date < danas))
                .ToList();

            foreach (var izbor in izbori)
            {
                if (danas < izbor.DatumPocetka.Date)
                {
                    izbor.Status = "Planiran";
                }
                else if (danas >= izbor.DatumPocetka.Date && danas <= izbor.DatumKraja.Date)
                {
                    izbor.Status = "U toku";
                }
                else
                {
                    izbor.Status = "Završen";
                }
            }

            if (izbori.Any())
                Context.SaveChanges();
        }

        public override void BeforeInsert(IzborInsetRequest request, Izbor entity)
        {
            ValidateIzbor(request.TipIzboraId, request.DatumPocetka, request.DatumKraja, request.Status, null);
        }

        public override void BeforeUpdate(IzborUpdateRequest request, Izbor entity)
        {
            ValidateIzbor(
                request.TipIzboraId ?? entity.TipIzboraId,
                request.DatumPocetka ?? entity.DatumPocetka,
                request.DatumKraja ?? entity.DatumKraja,
                request.Status ?? entity.Status,
                entity.Id
            );
        }

        private void ValidateIzbor(int tipIzboraId, DateTime datumPocetka, DateTime datumKraja, string status, int? izborId)
        {
            var tip = Context.TipIzboras.FirstOrDefault(x => x.Id == tipIzboraId);
            if (tip == null)
                throw new UserException("Tip izbora ne postoji.");

            if (datumPocetka > datumKraja)
                throw new UserException("Datum početka mora biti prije datuma kraja.");

            if (datumKraja < datumPocetka)
                throw new UserException("Datum kraja ne može biti manji od datuma početka.");

            var validStatuses = new[] { "Planiran", "U toku", "Završen" };
            if (!validStatuses.Contains(status))
                throw new UserException("Nevalidan status izbora.");

            var conflicting = Context.Izbors
                .Where(x => x.TipIzboraId == tipIzboraId &&
                    (izborId == null || x.Id != izborId) &&
                    (
                        (datumPocetka >= x.DatumPocetka && datumPocetka <= x.DatumKraja) ||
                        (datumKraja >= x.DatumPocetka && datumKraja <= x.DatumKraja)
                    )
                 ).Any();

            if (conflicting)
                throw new UserException("U bazi postoji izbor ovog tipa u istom vremenskom periodu.");
        }

        public bool CanDelete(int id)
        {
            bool imaKandidata = Context.Kandidats
                .Any(k => k.IzborId == id && k.Obrisan == false);

            if (imaKandidata)
                return false;

            bool imaGlasova = Context.Glas
                .Include(g => g.Kandidat)
                .Any(g => g.Kandidat.IzborId == id && g.Obrisan == false);

            if (imaGlasova)
                return false;

            return true;
        }

        public async Task<List<KandidatResponse>> GetKandidatiByIzborAsync(int izborId)
        {
            var izbor = await Context.Izbors.FindAsync(izborId);
            if (izbor == null)
                throw new UserException("Izbor ne postoji.");

            var kandidati = await Context.Kandidats
                .Where(k => k.IzborId == izborId && k.Obrisan == false)
                .Include(k => k.Stranka)
                .ToListAsync();

            var result = Mapper.Map<List<KandidatResponse>>(kandidati);

            foreach (var kandidat in result)
            {
                var entity = kandidati.First(k => k.Id == kandidat.Id);

                kandidat.Slika = entity.Slika != null
                    ? Convert.ToBase64String(entity.Slika)
                    : null;

                if (entity.Stranka != null)
                {
                    kandidat.Stranka.Logo = entity.Stranka.Logo != null
                        ? Convert.ToBase64String(entity.Stranka.Logo)
                        : null;
                }
            }

            return result;
        }

        public async Task<List<IzborResponse>> GetAktivniIzboriZaKorisnikaAsync(int korisnikId)
        {
            var danas = DateTime.Now;

            var korisnik = await Context.Korisniks
                .FirstOrDefaultAsync(k => k.Id == korisnikId && k.Obrisan == false);

            if (korisnik == null)
                throw new UserException("Korisnik nije pronađen.");

            var izbori = await Context.Izbors
                .Include(i => i.TipIzbora)
                    .ThenInclude(t => t.Opstina)
                        .ThenInclude(o => o.Grad)
                            .ThenInclude(g => g.Drzava)
                .Where(i =>
                    i.TipIzbora.OpstinaId == korisnik.OpstinaId &&
                    i.DatumPocetka <= danas &&
                    i.DatumKraja >= danas
                )
                .ToListAsync();

            return Mapper.Map<List<IzborResponse>>(izbori);
        }

    }
}
