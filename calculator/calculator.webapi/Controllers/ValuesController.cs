using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.EventHubs;

namespace calculator.webapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ValuesController : ControllerBase
    {

        // GET api/values
        [HttpGet("{op}")]
        public async Task<ActionResult<string>> GetAsync(int op,[FromQuery]string f1,[FromQuery]string f2 )
        {
            var c1 = Convert.ToInt32(f1);
            var c2 = Convert.ToInt32(f2);

            var results = 0;

         switch (op)
            {
                case 1:
                    results = c1 + c2;
                    break;
                case 2:
                    results = c1 - c2;
                    break;
                case 3:
                    results = c1 / c2;
                    break;
                case 4:
                    results = c1 * c2;
                    break;
            }

            var res = results.ToString();

                 await AddEvent(res);

                return "The result is: " + res;

          
        }

        public async Task AddEvent(string results)
        {

            EventHubClient eventHubClient;
            var EventHubConnectionString = Environment.GetEnvironmentVariable("SECRET_HUBCONN");

            var EventHubName = Environment.GetEnvironmentVariable("SECRET_HUBNS");

            var connectionStringBuilder = new EventHubsConnectionStringBuilder(EventHubConnectionString)
            {
                EntityPath = EventHubName
            };

            eventHubClient = EventHubClient.CreateFromConnectionString(connectionStringBuilder.ToString());

            try
            {
                await eventHubClient.SendAsync(new EventData(Encoding.UTF8.GetBytes(results)));
            }
            catch (Exception exception)
            {
                Console.WriteLine($"{DateTime.Now} > Exception: {exception.Message}");
            }



            await eventHubClient.CloseAsync();


        }

    }
}
