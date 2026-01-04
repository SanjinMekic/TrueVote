using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class StrankaController : BaseCRUDController<StrankaResponse, StrankaSearchObject, StrankaInsertRequest, StrankaUpdateRequest>
    {
        IStrankaService _service;
        public StrankaController(IStrankaService service) : base(service) 
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
        public override StrankaResponse Insert(StrankaInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override StrankaResponse Update(int id, StrankaUpdateRequest request)
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
