using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class OpstinaController : BaseCRUDController<OpstinaResponse, OpstinaSearchObject, OpstinaInsertRequest, OpstinaUpdateRequest>
    {
        IOpstinaService _service;
        public OpstinaController(IOpstinaService service) : base(service) 
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
        public override OpstinaResponse Insert(OpstinaInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override OpstinaResponse Update(int id, OpstinaUpdateRequest request)
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
