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
    public class PitanjeService : BaseCRUDService<PitanjeResponse, PitanjeSearchObject, Pitanje, PitanjeInsertRequest, PitanjeUpdateRequest>, IPitanjeService
    {
        public PitanjeService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Pitanje> AddFilter(PitanjeSearchObject search, IQueryable<Pitanje> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrEmpty(search.PitanjeText))
            {
                query = query.Where(p => p.PitanjeText.Contains(search.PitanjeText));
            }
            return query.Include(p => p.Kategorija);
        }
    }
}
