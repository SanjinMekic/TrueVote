using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class OpstinaController : BaseCRUDController<OpstinaResponse, OpstinaSearchObject, OpstinaInsertRequest, OpstinaUpdateRequest>
    {
        IOpstinaService _service;
        public OpstinaController(IOpstinaService service) : base(service) 
        {
            _service = service;
        }
    }
}
