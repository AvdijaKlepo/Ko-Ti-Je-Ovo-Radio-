﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class UserException : Exception
    {
		public UserException(string message) :
		   base(message)
		{ }
	}
}
