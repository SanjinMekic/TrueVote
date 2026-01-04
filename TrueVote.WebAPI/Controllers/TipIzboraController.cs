using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class TipIzboraController : BaseCRUDController<TipIzboraResponse, TipIzboraSearchObject, TipIzboraInsertRequest, TipIzboraUpdateRequest>
    {
        ITipIzboraService _service;
        public TipIzboraController(ITipIzboraService service) : base(service)
        {
            _service = service;
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("{id}/can-delete")]
        public ActionResult<bool> CanDelete(int id)
        {
            return Ok(new { canDelete = _service.CanDelete(id) });
        }

        [Authorize(Roles = "Admin")]
        public override TipIzboraResponse Insert(TipIzboraInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override TipIzboraResponse Update(int id, TipIzboraUpdateRequest request)
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
