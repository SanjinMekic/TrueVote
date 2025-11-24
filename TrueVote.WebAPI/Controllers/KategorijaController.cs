using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class KategorijaController : BaseCRUDController<KategorijaResponse, KategorijaSearchObject, KategorijaInsertRequest, KategorijaUpdateRequest>
    {
        IKategorijaService _service;
        public KategorijaController(IKategorijaService service) : base(service) 
        {
            _service = service;
        }
    }
}
