using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class IzborController : BaseCRUDController<IzborResponse, IzborSearchObject, IzborInsetRequest, IzborUpdateRequest>
    {
        IIzborService _service;
        public IzborController(IIzborService service) : base(service) 
        {
            _service = service;
        }

        [HttpGet("{id}/can-delete")]
        public ActionResult<bool> CanDelete(int id)
        {
            return Ok(new { canDelete = _service.CanDelete(id) });
        }

        [HttpGet("{izborId}/kandidati")]
        public async Task<IActionResult> GetKandidati(int izborId)
        {
            var result = await _service.GetKandidatiByIzborAsync(izborId);
            return Ok(result);
        }
    }
}
