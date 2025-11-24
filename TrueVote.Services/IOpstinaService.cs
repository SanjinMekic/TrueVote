using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;

namespace TrueVote.Services
{
    public interface IOpstinaService : ICRUDService<OpstinaResponse, OpstinaSearchObject, OpstinaInsertRequest, OpstinaUpdateRequest>
    {
    }
}
