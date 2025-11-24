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
    public class StrankaService : BaseCRUDService<StrankaResponse, StrankaSearchObject, Stranka, StrankaInsertRequest, StrankaUpdateRequest>, IStrankaService
    {
        public StrankaService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Stranka> AddFilter(StrankaSearchObject search, IQueryable<Stranka> query)
        {
            if (!string.IsNullOrEmpty(search.Naziv))
            {
                query = query.Where(s => s.Naziv.Contains(search.Naziv));
            }

            return query;   
        }
    }
}
