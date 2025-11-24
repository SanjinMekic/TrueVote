using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class GlasController : BaseCRUDController<GlasResponse, GlasSearchObject, GlasInsertRequest, GlasUpdateRequest>
    {
        IGlasService _service;
        public GlasController(IGlasService service) : base(service) 
        {
            _service = service;
        }
    }
}
