using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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
    }
}
