using Newtonsoft.Json;
using RabbitMQ.Client;
using Subscriber;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.RabbitMQ
{
	public class RabbitMQService : IRabbitMQService
	{
		public async Task SendEmail(Email email)
		{
			var hostname = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? "localhost";
			var username = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? "guest";
			var password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? "guest";
			var port = int.Parse(Environment.GetEnvironmentVariable("_rabbitMqPort") ?? "5672");

			var factory = new ConnectionFactory { HostName = hostname, UserName = username, Password = password, Port = port };
			using var connection = factory.CreateConnection();
			using var channel = connection.CreateModel();

			channel.QueueDeclare(queue: "mail_sending",
										  durable: false,
										  exclusive: false,
										  autoDelete: false,
										  arguments: null
										  );

			var body = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(email));

			channel.BasicPublish(exchange: string.Empty,
							  routingKey: "mail_sending",
							  basicProperties: null,
							  body: body);
		}
	}
}
