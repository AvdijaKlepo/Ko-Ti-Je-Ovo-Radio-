using DotNetEnv;
using MailKit.Net.Smtp;
using MimeKit;
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

				Env.Load();

				string fromAddress = Environment.GetEnvironmentVariable("_fromAddress") ?? "ko.radio.servis@gmail.com";
				string password = Environment.GetEnvironmentVariable("_password") ?? "password";
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

				email.From.Add(new MailboxAddress(displayName, fromAddress));
				email.To.Add(new MailboxAddress(emailObj.ReceiverName, emailObj.EmailTo));

				email.Subject = emailObj.Subject;
				email.Body = new TextPart(MimeKit.Text.TextFormat.Html)
				{
					Text = emailObj.Message
				};

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
