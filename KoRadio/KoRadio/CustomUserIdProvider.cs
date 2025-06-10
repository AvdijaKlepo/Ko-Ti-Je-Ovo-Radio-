using Microsoft.AspNetCore.SignalR;

namespace KoRadio.API
{
	public class CustomUserIdProvider : IUserIdProvider
	{
		public string? GetUserId(HubConnectionContext connection)
		{
			
			var httpContext = connection.GetHttpContext();
			return httpContext?.Request.Query["userId"];
		}
	}

}
