using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class StrankaInsertRequest
    {
        public string Naziv { get; set; }

        public string? Logo { get; set; }
    }
}
