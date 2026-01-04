using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class GradController : BaseCRUDController<GradResponse, GradSearchObject, GradInsertRequest, GradUpdateRequest>
    {
        IGradService _service;
        public GradController(IGradService service) : base(service) 
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
        public override GradResponse Insert(GradInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override GradResponse Update(int id, GradUpdateRequest request)
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
