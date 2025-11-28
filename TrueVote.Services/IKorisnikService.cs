using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Requests;
using TrueVote.Model.Responses;
using TrueVote.Model.SearchObjects;
using TrueVote.Services.Database;

namespace TrueVote.Services
{
    public interface IKorisnikService : ICRUDService<KorisnikResponse, KorisnikSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        KorisnikResponse Login(string username, string password);
        bool CanDelete(int id);
    }
}
