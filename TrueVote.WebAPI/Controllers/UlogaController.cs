using Microsoft.AspNetCore.Authorization;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class UlogaController : BaseCRUDController<UlogaResponse, UlogaSearchObject, UlogaInsertRequest, UlogaUpdateRequest>
    {
        IUlogaService _service;
        public UlogaController(IUlogaService service) : base(service) 
        {
            _service = service;
        }

        [Authorize(Roles = "Admin")]
        public override UlogaResponse Insert(UlogaInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override UlogaResponse Update(int id, UlogaUpdateRequest request)
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
