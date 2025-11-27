using MapsterMapper;
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
    public class KategorijaService : BaseCRUDService<KategorijaResponse, KategorijaSearchObject, Kategorija, KategorijaInsertRequest, KategorijaUpdateRequest>, IKategorijaService
    {
        public KategorijaService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Kategorija> AddFilter(KategorijaSearchObject search, IQueryable<Kategorija> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrEmpty(search.Naziv))
            {
                query = query.Where(k => k.Naziv.Contains(search.Naziv));
            }

            return query;
        }
    }
}
