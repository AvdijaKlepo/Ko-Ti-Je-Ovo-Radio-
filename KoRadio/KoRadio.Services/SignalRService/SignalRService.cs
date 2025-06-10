using Microsoft.AspNetCore.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.SignalRService
{
    public class SignalRHubService : Hub, ISignalRHubService
    {
		public override async Task OnConnectedAsync()
		{
			Console.WriteLine($"Klijent konektovan: {Context.ConnectionId}");
			await Task.Delay(100);
			await Clients.Caller.SendAsync("ReceiveConnectionId", Context.ConnectionId);
		
			await base.OnConnectedAsync();
			
		}

	}
}
