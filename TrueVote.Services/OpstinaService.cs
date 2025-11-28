using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
    public class OpstinaService : BaseCRUDService<OpstinaResponse, OpstinaSearchObject, Opstina, OpstinaInsertRequest, OpstinaUpdateRequest>, IOpstinaService
    {
        public OpstinaService(BirackiSistemContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Opstina> AddFilter(OpstinaSearchObject search, IQueryable<Opstina> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrEmpty(search.Naziv))
            {
                query = query.Where(o => o.Naziv.Contains(search.Naziv));
            }
            if (!string.IsNullOrEmpty(search.GradNaziv))
            {
                query = query.Where(o => o.Grad.Naziv.Contains(search.GradNaziv));
            }
            if (!string.IsNullOrEmpty(search.DrzavaNaziv))
            {
                query = query.Where(o => o.Grad.Drzava.Naziv.Contains(search.DrzavaNaziv));
            }
            return query.Include(o => o.Grad).ThenInclude(g => g.Drzava);
        }

        public bool CanDelete(int id)
        {
            // ima li korisnika
            bool imaKorisnika = Context.Korisniks
                .Any(k => k.OpstinaId == id && !k.Obrisan);

            if (imaKorisnika)
                return false;

            // ima li tipova izbora
            bool imaTipovaIzbora = Context.TipIzboras
                .Any(t => t.OpstinaId == id && !t.Obrisan);

            if (imaTipovaIzbora)
                return false;

            return true;
        }
    }
}
