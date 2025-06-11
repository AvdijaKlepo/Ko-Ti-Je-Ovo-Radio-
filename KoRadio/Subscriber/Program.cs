using DotNetEnv;

using Newtonsoft.Json;
using Org.BouncyCastle.Security;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Subscriber.MailSenderService;
using Subscriber;
using System.Net.WebSockets;
using System.Text;


Env.Load();
var emailService = new MailSenderService();
Task.Delay(10000).Wait();

Task.Delay(1000).Wait();
var hostname = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? "localhost";
var username = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? "guest";
var password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? "guest";
var port = int.Parse(Environment.GetEnvironmentVariable("_rabbitMqPort") ?? "5672");

ConnectionFactory factory = new ConnectionFactory() { HostName = hostname, Port = port };
factory.UserName = username;
factory.Password = password;
IConnection connection = factory.CreateConnection();
IModel channel = connection.CreateModel();
channel.QueueDeclare(queue: "mail_sending",
						durable: false,
						exclusive: false,
						autoDelete: false,
						arguments: null);



var consumer = new EventingBasicConsumer(channel);
consumer.Received += async (sender, args) =>
{
	try
	{
		var body = args.Body.ToArray();
		var message = Encoding.UTF8.GetString(body);

		Console.WriteLine($"Message received: {message}");

		var entity = JsonConvert.DeserializeObject<Email>(message);
		Console.WriteLine(entity?.EmailTo);
		if (entity != null)
		{
			await emailService.SendEmail(entity);
		}
	}
	catch (Exception ex)
	{
		Console.WriteLine($"Error processing message: {ex.Message}");
	}
};


channel.BasicConsume(queue: "mail_sending",
					 autoAck: true,
					 consumer: consumer);


Thread.Sleep(Timeout.Infinite);

Console.ReadLine();