using Microsoft.AspNetCore.Authorization;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class KategorijaController : BaseCRUDController<KategorijaResponse, KategorijaSearchObject, KategorijaInsertRequest, KategorijaUpdateRequest>
    {
        IKategorijaService _service;
        public KategorijaController(IKategorijaService service) : base(service) 
        {
            _service = service;
        }

        [Authorize(Roles = "Admin")]
        public override KategorijaResponse Insert(KategorijaInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override KategorijaResponse Update(int id, KategorijaUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }
    }
}
