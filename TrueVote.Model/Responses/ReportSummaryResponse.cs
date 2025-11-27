using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class ReportSummaryResponse
    {
        public int BrojDrzava { get; set; }
        public int BrojGradova { get; set; }
        public int BrojOpstina { get; set; }
        public int BrojStranaka { get; set; }
        public int BrojKorisnika { get; set; }
        public int BrojBiraca { get; set; }
        public int BrojAdmina { get; set; }
        public int BrojKandidata { get; set; }
        public int BrojIzbora { get; set; }
        public int BrojFaqPitanja { get; set; }
    }
}