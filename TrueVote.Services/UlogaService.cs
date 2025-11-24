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
    public class UlogaService : BaseCRUDService<UlogaResponse, UlogaSearchObject, Uloga, UlogaInsertRequest, UlogaUpdateRequest>, IUlogaService
    {
        public UlogaService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Uloga> AddFilter(UlogaSearchObject search, IQueryable<Uloga> query)
        {
            if (!string.IsNullOrEmpty(search.Naziv))
            {
                query = query.Where(u => u.Naziv.Contains(search.Naziv));
            }

            return query;
        }
    }
}
