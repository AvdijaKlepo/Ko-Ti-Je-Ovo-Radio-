using DotNetEnv;
using MailKit.Net.Smtp;
using MimeKit;
using MimeKit.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Subscriber.MailSenderService.MailSenderService;
namespace Subscriber.MailSenderService
{
    public class MailSenderService
    {
		
			public async Task SendEmail(Email emailObj)
			{
				if (emailObj == null) return;

			Env.Load(Path.Combine(AppContext.BaseDirectory, @"..\..\..\..\.env"));



			string fromAddress = Environment.GetEnvironmentVariable("_fromAddress") ?? "ko.radio.servis@gmail.com";
				string password = Environment.GetEnvironmentVariable("_password") ?? "";
				string host = Environment.GetEnvironmentVariable("_host") ?? "smtp.gmail.com";
				int port = int.Parse(Environment.GetEnvironmentVariable("_port") ?? "465");
				bool enableSSL = bool.Parse(Environment.GetEnvironmentVariable("_enableSSL") ?? "true");
				string displayName = Environment.GetEnvironmentVariable("_displayName") ?? "no-reply";
				int timeout = int.Parse(Environment.GetEnvironmentVariable("_timeout") ?? "255");

				if (password == string.Empty)
				{
					Console.WriteLine("Password je prazan.");
					return;
				}

			var email = new MimeMessage();
			email.From.Add(new MailboxAddress("no-reply", "ko.radio.servis@gmail.com"));
			email.To.Add(new MailboxAddress(emailObj.ReceiverName, emailObj.EmailTo));
			email.Subject = emailObj.Subject;

	
			var builder = new BodyBuilder
			{
				HtmlBody = emailObj.Message
			};

			if (emailObj.PdfBytes != null && emailObj.PdfBytes.Length > 0)
			{
				builder.Attachments.Add(emailObj.AttachmentFileName,
										emailObj.PdfBytes,
										new ContentType("application", "pdf"));
			}

	
			if (emailObj.InlineImageBytes != null && emailObj.InlineImageBytes.Length > 0)
			{
				var image = builder.LinkedResources.Add("preview.png", emailObj.PdfBytes);
				image.ContentId = MimeUtils.GenerateMessageId();

				builder.HtmlBody += $"<br/><p>Pregled novog kataloga:</p>" +
									$"<img src=\"cid:{image.ContentId}\" style='max-width:500px;' />";
			}



			email.Body = builder.ToMessageBody();

			try
				{
					Console.WriteLine("Spajanje na SMTP server...");

					using (var smtp = new SmtpClient())
					{
						await smtp.ConnectAsync(host, port, enableSSL);
						Console.WriteLine("Uspješno spojeno na SMTP server...");

						await smtp.AuthenticateAsync(fromAddress, password);
						Console.WriteLine("Autentifikacija na SMTP serveru uspješna.");

						await smtp.SendAsync(email);


						await smtp.DisconnectAsync(true);
					}
					Console.WriteLine("Mail uspjesno poslan.");
				}
				catch (Exception ex)
				{
					Console.WriteLine($"Error {ex.Message}");
					return;
				}
			}
		}
	
}
