using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;

namespace TrueVote.Services
{
    public interface IGlasService : ICRUDService<GlasResponse, GlasSearchObject, GlasInsertRequest, GlasUpdateRequest>
    {
        Task<int> GetUkupanBrojGlasovaZaKandidataAsync(int kandidatId);
        Task<bool> JeLiKorisnikZavrsioGlasanjeAsync(int izborId, int korisnikId);
    }
}
