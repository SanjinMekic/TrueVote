using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class StrankaController : BaseCRUDController<StrankaResponse, StrankaSearchObject, StrankaInsertRequest, StrankaUpdateRequest>
    {
        IStrankaService _service;
        public StrankaController(IStrankaService service) : base(service) 
        {
            _service = service;
        }
    }
}
