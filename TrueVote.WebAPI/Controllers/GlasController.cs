using Microsoft.AspNetCore.Mvc;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    public class GlasController : BaseCRUDController<GlasResponse, GlasSearchObject, GlasInsertRequest, GlasUpdateRequest>
    {
        IGlasService _service;
        public GlasController(IGlasService service) : base(service) 
        {
            _service = service;
        }

        [HttpGet("kandidat/{kandidatId}/broj-glasova")]
        public async Task<IActionResult> GetBrojGlasovaZaKandidata(int kandidatId)
        {
            var broj = await _service.GetUkupanBrojGlasovaZaKandidataAsync(kandidatId);
            return Ok(broj);
        }

        [HttpGet("provjera-zavrsenog-glasanja")]
        public async Task<IActionResult> JeLiZavrsioGlasanje(
            [FromQuery] int izborId,
            [FromQuery] int korisnikId)
        {
            var zavrsio = await _service
                .JeLiKorisnikZavrsioGlasanjeAsync(izborId, korisnikId);

            return Ok(new { zavrsio });
        }
    }
}
