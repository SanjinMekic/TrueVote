using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class GradUpdateRequest
    {
        public string? Naziv { get; set; }

        public int? DrzavaId { get; set; }
    }
}
