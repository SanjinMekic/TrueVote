using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class DrzavaController : BaseCRUDController<DrzavaResponse, DrzavaSearchObject, DrzavaInsertRequest, DrzavaUpdateRequest>
    {
        IDrzavaService _service;
        public DrzavaController(IDrzavaService service) : base(service)
        {
            _service = service;
        }
    }
}
