using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class OpstinaResponse
    {
        public int Id { get; set; }

        public string Naziv { get; set; } = null!;

        public int GradId { get; set; }

        public GradResponse Grad { get; set; }
    }
}
