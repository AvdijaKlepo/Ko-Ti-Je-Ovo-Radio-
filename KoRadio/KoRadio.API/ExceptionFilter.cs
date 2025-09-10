using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;
using System.Net;
using System.Runtime.InteropServices;
using KoRadio.Model;

namespace KoRadio.API
{
	public class ExceptionFilter : ExceptionFilterAttribute
	{
		private ILogger<ExceptionFilter> _logger;
		public ExceptionFilter(ILogger<ExceptionFilter> logger)
		{
			_logger = logger;
		}
		public override void OnException(ExceptionContext context)
		{
			_logger.LogError(context.Exception, context.Exception.Message);

			if (context.HttpContext.Response.HasStarted)
			{
				_logger.LogWarning("The response has already started, the exception filter will not execute.");
				return;
			}

			if (context.Exception is UserException)
			{
				context.ModelState.AddModelError("userError", context.Exception.Message);
				context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
			}
			else
			{
				context.ModelState.AddModelError("ERROR", "Server side error, please check logs.");
				context.HttpContext.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
			}

			var list = context.ModelState
				.Where(x => x.Value.Errors.Count > 0)
				.ToDictionary(x => x.Key, y => y.Value.Errors.Select(z => z.ErrorMessage));

			context.Result = new JsonResult(new { errors = list });
		}

	}
}
