using Microsoft.AspNetCore.Authorization;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services;

namespace TrueVote.WebAPI.Controllers
{
    [Authorize]
    public class PitanjeController : BaseCRUDController<PitanjeResponse, PitanjeSearchObject, PitanjeInsertRequest, PitanjeUpdateRequest>
    {
        IPitanjeService _service;
        public PitanjeController(IPitanjeService service) : base(service)
        {
        }

        [Authorize(Roles = "Admin")]
        public override PitanjeResponse Insert(PitanjeInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override PitanjeResponse Update(int id, PitanjeUpdateRequest request)
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
