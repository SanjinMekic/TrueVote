using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueVote.Model.Responses;

namespace TrueVote.Services
{
    public interface IReportService
    {
        ReportSummaryResponse GetSummary();
    }
}
