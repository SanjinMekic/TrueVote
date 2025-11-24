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
    public class IzborService : BaseCRUDService<IzborResponse, IzborSearchObject, Izbor, IzborInsetRequest, IzborUpdateRequest>, IIzborService
    {
        public IzborService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Izbor> AddFilter(IzborSearchObject search, IQueryable<Izbor> query)
        {
            if (!string.IsNullOrEmpty(search.Status))
            {
                query = query.Where(i => i.Status == search.Status);
            }
            if (search.DatumPocetka.HasValue && !search.DatumKraja.HasValue)
            {
                query = query.Where(i => i.DatumPocetka.Date >= search.DatumPocetka.Value.Date);
            }
            if (!search.DatumPocetka.HasValue && search.DatumKraja.HasValue)
            {
                query = query.Where(i => i.DatumKraja.Date <= search.DatumKraja.Value.Date);
            }
            if (search.DatumPocetka.HasValue && search.DatumKraja.HasValue)
            {
                query = query.Where(i => i.DatumPocetka.Date >= search.DatumPocetka.Value.Date && i.DatumKraja.Date <= search.DatumKraja.Value.Date);
            }
            return base.AddFilter(search, query).Include(i => i.TipIzbora)
                .ThenInclude(ti => ti.Opstina)
                .ThenInclude(o => o.Grad)
                .ThenInclude(g => g.Drzava);
        }
    }
}
