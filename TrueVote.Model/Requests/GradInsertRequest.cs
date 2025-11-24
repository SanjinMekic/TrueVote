using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Requests
{
    public class GradInsertRequest
    {
        public string Naziv { get; set; }

        public int DrzavaId { get; set; }
    }
}
