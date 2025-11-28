using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
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

        [HttpGet("{id}/can-delete")]
        public ActionResult<bool> CanDelete(int id)
        {
            return Ok(new { canDelete = _service.CanDelete(id) });
        }
    }
}
