using System;
using System.Collections.Generic;
using System.Text;

namespace TrueVote.Model.Responses
{
    public class StrankaResponse
    {
        public int Id { get; set; }

        public string Naziv { get; set; }
        public byte[] Logo { get; set; }
    }
}
