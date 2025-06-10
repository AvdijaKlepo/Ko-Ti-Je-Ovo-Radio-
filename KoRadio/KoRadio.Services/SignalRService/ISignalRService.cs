using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.SignalRService
{
    public interface ISignalRHubService
    {
        Task OnConnectedAsync();
    }
}
