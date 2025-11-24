using Microsoft.AspNetCore.Authorization;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class PitanjeController : BaseCRUDController<PitanjeResponse, PitanjeSearchObject, PitanjeInsertRequest, PitanjeUpdateRequest>
    {
        IPitanjeService _service;
        public PitanjeController(IPitanjeService service) : base(service)
        {
        }
    }
}
