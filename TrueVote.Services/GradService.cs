using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
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
    public class GradService : BaseCRUDService<GradResponse, GradSearchObject, Grad, GradInsertRequest, GradUpdateRequest>, IGradService
    {
        public GradService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Grad> AddFilter(GradSearchObject search, IQueryable<Grad> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrEmpty(search.Naziv))
            {
                query = query.Where(g => g.Naziv.Contains(search.Naziv)).Include(g => g.Drzava);
            }
            if (!string.IsNullOrEmpty(search.DrzavaNaziv))
            {
                query = query.Include(g => g.Drzava).Where(g => g.Drzava.Naziv.Contains(search.DrzavaNaziv));
            }
            return query.Include(g => g.Drzava);
        }

        public bool CanDelete(int id)
        {
            var imaOpstina = Context.Opstinas
                .Any(o => o.GradId == id && o.Obrisan == false);

            return !imaOpstina;
        }
    }
}
