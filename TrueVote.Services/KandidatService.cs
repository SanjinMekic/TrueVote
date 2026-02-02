using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Exceptions;
using TrueVote.Model.Models;
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
            query = base.AddFilter(search, query);

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
            if (!string.IsNullOrEmpty(search.IzborNaziv))
            {
                query = query.Where(k => k.Izbor.TipIzbora.Naziv.Contains(search.IzborNaziv));
            }
            return query.Include(k => k.Izbor).ThenInclude(i => i.TipIzbora).ThenInclude(ti => ti.Opstina).ThenInclude(o => o.Grad).ThenInclude(g => g.Drzava).Include(k => k.Stranka);
        }

        public override PagedResult<KandidatResponse> GetPaged(KandidatSearchObject search)
        {
            var paged = base.GetPaged(search);

            foreach (var item in paged.ResultList)
            {
                var entity = Context.Set<Kandidat>().Find(item.Id);

                if (entity != null)
                {
                    item.Slika = entity.Slika != null
                        ? Convert.ToBase64String(entity.Slika)
                        : null;
                }
            }

            return paged;
        }

        public override KandidatResponse GetById(int id)
        {
            var entity = Context.Set<Kandidat>()
                .Include(k => k.Stranka)
                .Include(k => k.Izbor).ThenInclude(i => i.TipIzbora)
                .FirstOrDefault(k => k.Id == id);

            if (entity == null)
                return null;

            var model = Mapper.Map<KandidatResponse>(entity);

            model.Slika = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            return model;
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

            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                try
                {
                    entity.Slika = Convert.FromBase64String(request.SlikaBase64);
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

            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                try
                {
                    entity.Slika = Convert.FromBase64String(request.SlikaBase64);
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
            var izbor = Context.Izbors
                .Include(x => x.TipIzbora)
                .FirstOrDefault(x => x.Id == izborId);

            if (izbor == null)
                throw new UserException("Izbor ne postoji.");

            if (izbor.Status == "Završen")
                throw new UserException("Kandidate možete dodavati samo dok je izbor u statusu 'Planiran' ili 'U toku'.");

            if (strankaId.HasValue)
            {
                if (!Context.Strankas.Any(x => x.Id == strankaId.Value))
                    throw new UserException("Odabrana stranka ne postoji.");
            }

            bool duplicate = Context.Kandidats.Any(x =>
                x.IzborId == izborId &&
                x.Ime == ime &&
                x.Prezime == prezime &&
                (kandidatId == null || x.Id != kandidatId)
            );

            if (duplicate)
                throw new UserException("Kandidat sa istim imenom i prezimenom već postoji na ovom izboru.");
        }

        public bool CanDelete(int id)
        {
            var kandidat = Context.Kandidats.Find(id);

            if (kandidat == null)
                return false;

            bool imaGlasova = Context.Glas.Any(g => g.KandidatId == id && g.Obrisan == false);

            if (imaGlasova)
                return false;

            return true;
        }
    }
}
