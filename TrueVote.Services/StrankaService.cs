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
    }
}
