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
    public class OpstinaService : BaseCRUDService<OpstinaResponse, OpstinaSearchObject, Opstina, OpstinaInsertRequest, OpstinaUpdateRequest>, IOpstinaService
    {
        public OpstinaService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Opstina> AddFilter(OpstinaSearchObject search, IQueryable<Opstina> query)
        {
            return query.Include(o => o.Grad).ThenInclude(g => g.Drzava);
        }
    }
}
