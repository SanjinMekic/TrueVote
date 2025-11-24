using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class IzborController : BaseCRUDController<IzborResponse, IzborSearchObject, IzborInsetRequest, IzborUpdateRequest>
    {
        IIzborService _service;
        public IzborController(IIzborService service) : base(service) 
        {
            _service = service;
        }
    }
}
