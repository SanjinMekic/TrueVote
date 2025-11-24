using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class GradController : BaseCRUDController<GradResponse, GradSearchObject, GradInsertRequest, GradUpdateRequest>
    {
        IGradService _service;
        public GradController(IGradService service) : base(service) 
        {
            _service = service;
        }
    }
}
