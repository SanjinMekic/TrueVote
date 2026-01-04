using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class KorisnikController : BaseCRUDController<KorisnikResponse, KorisnikSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        IKorisnikService _service;
        public KorisnikController(IKorisnikService service) : base(service)
        {
            _service = service; 
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public ActionResult<KorisnikResponse> Login([FromBody] LoginRequest loginRequest)
        {
            var user = (_service as IKorisnikService).Login(loginRequest.Username, loginRequest.Password);
            if (user == null)
            {
                return Unauthorized("Pogresno korisnicko ime ili lozinka");
            }
            return Ok(user);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("{id}/can-delete")]
        public ActionResult<bool> CanDelete(int id)
        {
            return Ok(new { canDelete = _service.CanDelete(id) });
        }

        [HttpPost("{id}/pin")]
        [Authorize(Roles = "Birac")]
        public async Task<IActionResult> KreirajPin(int id, [FromBody] string request)
        {
            var result = await _service.KreirajPinAsync(id, request);

            if (!result)
                return BadRequest("PIN nije kreiran.");

            return Ok(new { message = "PIN uspješno kreiran." });
        }

        [HttpPost("{id}/pin/provjera")]
        [Authorize(Roles = "Birac")]
        public async Task<IActionResult> ProvjeriPin(int id, [FromBody] string request)
        {
            var isValid = await _service.ProvjeriPinAsync(id, request);

            return Ok(new { valid = isValid });
        }

        [HttpPut("{id}/promijeni-pin")]
        [Authorize(Roles = "Birac")]
        public async Task<IActionResult> PromijeniPin(int id, [FromBody] PromjeniPinRequest request)
        {
            await _service.PromijeniPinAsync(id, request.StariPin, request.NoviPin);
            return Ok(new { message = "PIN uspješno promijenjen." });
        }

        [Authorize(Roles = "Admin")]
        public override KorisnikResponse Insert(KorisnikInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }
    }
}
