using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class DrzavaController : BaseCRUDController<DrzavaResponse, DrzavaSearchObject, DrzavaInsertRequest, DrzavaUpdateRequest>
    {
        IDrzavaService _service;
        public DrzavaController(IDrzavaService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("{id}/can-delete")]
        public IActionResult CanDelete(int id)
        {
            return Ok(new { canDelete = _service.CanDelete(id) });
        }
    }
}
