using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class IzborController : BaseCRUDController<IzborResponse, IzborSearchObject, IzborInsetRequest, IzborUpdateRequest>
    {
        IIzborService _service;
        public IzborController(IIzborService service) : base(service) 
        {
            _service = service;
        }

        [Authorize(Roles = "Admin")]
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

        [Authorize(Roles = "Birac")]
        [HttpGet("aktivni-izbori/korisnik/{korisnikId}")]
        public async Task<IActionResult> GetAktivniIzboriZaKorisnika(int korisnikId)
        {
            var result = await _service.GetAktivniIzboriZaKorisnikaAsync(korisnikId);
            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        public override IzborResponse Insert(IzborInsetRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override IzborResponse Update(int id, IzborUpdateRequest request)
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
