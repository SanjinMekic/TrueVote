using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class TipIzboraController : BaseCRUDController<TipIzboraResponse, TipIzboraSearchObject, TipIzboraInsertRequest, TipIzboraUpdateRequest>
    {
        ITipIzboraService _service;
        public TipIzboraController(ITipIzboraService service) : base(service)
        {
            _service = service;
        }
    }
}
