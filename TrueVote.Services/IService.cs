using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Models;
using TrueVote.Model.SearchObjects;

namespace TrueVote.Services
{
    public interface IService<TModel, TSearch> where TSearch : BaseSearchObject
    {
        public PagedResult<TModel> GetPaged(TSearch search);
        public TModel GetById(int id);
    }
}
