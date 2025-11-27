using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.SearchObjects;
using TrueVote.Services.Database;

namespace TrueVote.Services
{
    public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseService<TModel, TSearch, TDbEntity> where TModel : class where TSearch : BaseSearchObject where TDbEntity : class
    {
        protected readonly IMapper Mapper;
        protected BaseCRUDService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
            Mapper = mapper;
        }

        public virtual TModel Insert(TInsert request)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(request);

            BeforeInsert(request, entity);
            Context.Add(entity);

            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeInsert(TInsert request, TDbEntity entity) { }

        public virtual TModel Update(int id, TUpdate request)
        {
            var set = Context.Set<TDbEntity>();

            var entity = set.Find(id);

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeUpdate(TUpdate request, TDbEntity entity) { }

        public virtual void Delete(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);

            if (entity == null)
                throw new Exception("Entity not found");

            // Provjera da li TDbEntity ima svojstvo Obrisan
            var prop = entity.GetType().GetProperty("Obrisan");

            if (prop == null)
                throw new Exception("Ova entitetska klasa nema 'Obrisan' polje — soft delete nije moguće.");

            // Postavljanje vrijednosti
            prop.SetValue(entity, true);

            Context.SaveChanges();
        }

        public virtual void Restore(int id)
        {
            var set = Context.Set<TDbEntity>();
            var entity = set.Find(id);

            if (entity == null)
                throw new Exception("Entity not found");

            var prop = entity.GetType().GetProperty("Obrisan");

            if (prop == null)
                throw new Exception("Ova entitetska klasa nema 'Obrisan' polje — restore nije moguće.");

            prop.SetValue(entity, false);

            Context.SaveChanges();
        }
    }
}
