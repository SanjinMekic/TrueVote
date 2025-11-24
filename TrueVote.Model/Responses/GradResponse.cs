using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class GradResponse
    {
        public int Id { get; set; }

        public string Naziv { get; set; }

        public int DrzavaId { get; set; }

        public DrzavaResponse Drzava { get; set; }
    }
}
