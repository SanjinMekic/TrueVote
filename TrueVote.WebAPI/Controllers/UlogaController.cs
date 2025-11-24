using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class UlogaController : BaseCRUDController<UlogaResponse, UlogaSearchObject, UlogaInsertRequest, UlogaUpdateRequest>
    {
        IUlogaService _service;
        public UlogaController(IUlogaService service) : base(service) 
        {
            _service = service;
        }
    }
}
