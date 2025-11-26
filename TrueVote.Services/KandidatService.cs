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
    public class KandidatService : BaseCRUDService<KandidatResponse, KandidatSearchObject, Kandidat, KandidatInsertRequest, KandidatUpdateRequest>, IKandidatService
    {
        public KandidatService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Kandidat> AddFilter(KandidatSearchObject search, IQueryable<Kandidat> query)
        {
            if (!string.IsNullOrEmpty(search.Ime))
            {
                query = query.Where(k => k.Ime.Contains(search.Ime));
            }
            if (!string.IsNullOrEmpty(search.Prezime))
            {
                query = query.Where(k => k.Prezime.Contains(search.Prezime));
            }
            if (!string.IsNullOrEmpty(search.StrankaNaziv))
            {
                query = query.Where(k => k.Stranka != null && k.Stranka.Naziv.Contains(search.StrankaNaziv));
            }
            if (search.IzborId.HasValue)
            {
                query = query.Where(k => k.IzborId == search.IzborId);
            }
            return query.Include(k => k.Izbor).Include(k => k.Stranka);
        }

        public override void BeforeInsert(KandidatInsertRequest request, Kandidat entity)
        {
            ValidateKandidat(
                request.Ime,
                request.Prezime,
                request.StrankaId,
                request.IzborId,
                null
            );

            // Base64 → byte[]
            if (!string.IsNullOrEmpty(request.Slika))
            {
                try
                {
                    entity.Slika = Convert.FromBase64String(request.Slika);
                }
                catch
                {
                    throw new UserException("Slika mora biti validan Base64 string.");
                }
            }
            else
            {
                entity.Slika = null;
            }
        }


        public override void BeforeUpdate(KandidatUpdateRequest request, Kandidat entity)
        {
            ValidateKandidat(
                request.Ime ?? entity.Ime,
                request.Prezime ?? entity.Prezime,
                request.StrankaId ?? entity.StrankaId,
                request.IzborId ?? entity.IzborId,
                entity.Id
            );

            // Ako je poslata nova slika
            if (!string.IsNullOrEmpty(request.Slika))
            {
                try
                {
                    entity.Slika = Convert.FromBase64String(request.Slika);
                }
                catch
                {
                    throw new UserException("Slika mora biti validan Base64 string.");
                }
            }
        }


        private void ValidateKandidat(
            string ime,
            string prezime,
            int? strankaId,
            int izborId,
            int? kandidatId)
        {
            // 1. Izbor mora postojati
            var izbor = Context.Izbors
                .Include(x => x.TipIzbora)
                .FirstOrDefault(x => x.Id == izborId);

            if (izbor == null)
                throw new UserException("Izbor ne postoji.");

            // 2. Izbor mora biti u statusu Planned
            if (izbor.Status != "Planned")
                throw new UserException("Kandidate možete dodavati samo dok je izbor u statusu 'Planned'.");

            // 3. Stranka mora postojati (ako je navedena)
            if (strankaId.HasValue)
            {
                if (!Context.Strankas.Any(x => x.Id == strankaId.Value))
                    throw new UserException("Odabrana stranka ne postoji.");
            }

            // 4. Unikatnost kandidata u okviru jednog izbora
            bool duplicate = Context.Kandidats.Any(x =>
                x.IzborId == izborId &&
                x.Ime == ime &&
                x.Prezime == prezime &&
                (kandidatId == null || x.Id != kandidatId)
            );

            if (duplicate)
                throw new UserException("Kandidat sa istim imenom i prezimenom već postoji na ovom izboru.");
        }
    }
}
