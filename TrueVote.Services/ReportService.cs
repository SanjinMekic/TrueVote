using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Responses;
using TrueVote.Services.Database;

namespace TrueVote.Services
{
    public class ReportService : IReportService
    {
        private readonly BirackiSistemContext _context;

        public ReportService(BirackiSistemContext context)
        {
            _context = context;
        }

        public ReportSummaryResponse GetSummary()
        {
            return new ReportSummaryResponse
            {
                BrojDrzava = _context.Drzavas.Count(x => x.Obrisan == false),
                BrojGradova = _context.Grads.Count(x => x.Obrisan == false),
                BrojOpstina = _context.Opstinas.Count(x => x.Obrisan == false),
                BrojStranaka = _context.Strankas.Count(x => x.Obrisan == false),

                BrojKorisnika = _context.Korisniks.Count(x => x.Obrisan == false),

                BrojBiraca = _context.Korisniks.Count(x =>
                    x.UlogaId == 2 && x.Obrisan == false),

                BrojAdmina = _context.Korisniks.Count(x =>
                    x.UlogaId == 1 && x.Obrisan == false),

                BrojKandidata = _context.Kandidats.Count(x => x.Obrisan == false),

                BrojIzbora = _context.Izbors.Count(x => x.Obrisan == false),

                BrojFaqPitanja = _context.Pitanjes.Count(x => x.Obrisan == false)
            };
        }
    }
}
