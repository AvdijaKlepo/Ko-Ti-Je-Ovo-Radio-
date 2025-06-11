using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.RabbitMQ
{
    public interface IRabbitMQService
    {
		Task SendEmail(Subscriber.Email email);
	}
}
