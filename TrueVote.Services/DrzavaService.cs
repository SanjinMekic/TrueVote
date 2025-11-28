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
    public class DrzavaService : BaseCRUDService<DrzavaResponse, DrzavaSearchObject, Drzava, DrzavaInsertRequest, DrzavaUpdateRequest>, IDrzavaService
    {
        public DrzavaService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Drzava> AddFilter(DrzavaSearchObject search, IQueryable<Drzava> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrEmpty(search.Naziv))
            {
                query = query.Where(d => d.Naziv.Contains(search.Naziv));
            }

            return query;
        }

        public bool CanDelete(int id)
        {
            bool imaGradova = Context.Grads
                .Any(g => g.DrzavaId == id && g.Obrisan == false);

            return !imaGradova;
        }
    }
}
