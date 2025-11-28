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
    public class TipIzboraService : BaseCRUDService<TipIzboraResponse, TipIzboraSearchObject, TipIzbora, TipIzboraInsertRequest, TipIzboraUpdateRequest>, ITipIzboraService
    {
        public TipIzboraService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<TipIzbora> AddFilter(TipIzboraSearchObject search, IQueryable<TipIzbora> query)
        {
            query = base.AddFilter(search, query);

            return query.Include(ti => ti.Opstina).ThenInclude(o => o.Grad).ThenInclude(g => g.Drzava);
        }

        public bool CanDelete(int id)
        {
            var tip = Context.TipIzboras.Include(t => t.Izbors)
                                        .FirstOrDefault(t => t.Id == id && t.Obrisan == false);

            if (tip == null)
                return false;

            if (tip.Izbors.Any(i => !i.Obrisan))
                return false;

            return true;
        }
    }
}
