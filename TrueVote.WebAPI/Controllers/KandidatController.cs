using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class KandidatController : BaseCRUDController<KandidatResponse, KandidatSearchObject, KandidatInsertRequest, KandidatUpdateRequest>
    {
        IKandidatService _service;
        public KandidatController(IKandidatService service) : base(service) 
        {
            _service = service;
        }
    }
}
