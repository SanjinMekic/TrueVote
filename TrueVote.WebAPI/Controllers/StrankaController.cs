using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class StrankaController : BaseCRUDController<StrankaResponse, StrankaSearchObject, StrankaInsertRequest, StrankaUpdateRequest>
    {
        IStrankaService _service;
        public StrankaController(IStrankaService service) : base(service) 
        {
            _service = service;
        }

        [HttpGet("{id}/can-delete")]
        public ActionResult<bool> CanDelete(int id)
        {
            return Ok(new { canDelete = _service.CanDelete(id) });
        }
    }
}
