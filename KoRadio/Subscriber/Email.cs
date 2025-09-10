using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Subscriber
{
	public class Email
	{
		public string EmailTo { get; set; }
		public string ReceiverName { get; set; }
		public string Subject { get; set; }
		public string Message { get; set; }

		// direct binary file
		public byte[]? PdfBytes { get; set; }

		// optional inline preview
		public byte[]? InlineImageBytes { get; set; }

		// optional filename
		public string AttachmentFileName { get; set; } = "Katalog.pdf";
	}

}
