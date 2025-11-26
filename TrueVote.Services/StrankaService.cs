using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Models;
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

        public override void BeforeInsert(StrankaInsertRequest request, Stranka entity)
        {
            if (!string.IsNullOrEmpty(request.LogoBase64))
            {
                try
                {
                    entity.Logo = Convert.FromBase64String(request.LogoBase64);
                }
                catch
                {
                    throw new Exception("Logo nije validan Base64 format.");
                }
            }
        }

        public override void BeforeUpdate(StrankaUpdateRequest request, Stranka entity)
        {
            if (!string.IsNullOrEmpty(request.LogoBase64))
            {
                try
                {
                    entity.Logo = Convert.FromBase64String(request.LogoBase64);
                }
                catch
                {
                    throw new Exception("Logo nije validan Base64 format.");
                }
            }
        }

        public override PagedResult<StrankaResponse> GetPaged(StrankaSearchObject search)
        {
            var paged = base.GetPaged(search);

            foreach (var item in paged.ResultList)
            {
                var entity = Context.Set<Stranka>().Find(item.Id);

                if (entity != null)
                {
                    item.Logo = entity.Logo != null
                        ? Convert.ToBase64String(entity.Logo)
                        : null;
                }
            }

            return paged;
        }

        public override StrankaResponse GetById(int id)
        {
            var entity = Context.Set<Stranka>().Find(id);

            if (entity == null)
                return null;

            var model = Mapper.Map<StrankaResponse>(entity);

            model.Logo = entity.Logo != null
                ? Convert.ToBase64String(entity.Logo)
                : null;

            return model;
        }
    }
}
