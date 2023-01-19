using Microsoft.AspNetCore.Mvc;
using System.Collections;
using System.Text;
using System.IO;
using Microsoft.AspNetCore.Hosting.Server;
using System.Reflection.PortableExecutable;
using System.Xml.Linq;
using Newtonsoft.Json;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace demo_app.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EnvsController : ControllerBase
    {
        // GET: api/<EnvsController>
        [HttpGet]
        public async Task<string> Get()
        {
            StringBuilder sb = new StringBuilder();

            foreach (DictionaryEntry de in Environment.GetEnvironmentVariables())
                sb.AppendLine($"{de.Key, -50} | {de.Value}");

            await AddServiceInformationFromApi(sb);

            return sb.ToString();
        }

        private async Task<string> AddServiceInformationFromApi(StringBuilder sb)
        {
            //Path to ServiceAccount token
            string serviceAccount = "/var/run/secrets/kubernetes.io/serviceaccount";
            sb.AppendLine($"{nameof(serviceAccount),-50} | {serviceAccount}");

            // Read the ServiceAccount bearer token
            string token = System.IO.File.ReadAllText(serviceAccount + "/token");

            // Make an HTTP request, and omit the SSL validation
            HttpClientHandler handler = new HttpClientHandler();
            handler.ServerCertificateCustomValidationCallback = HttpClientHandler.DangerousAcceptAnyServerCertificateValidator;
            using (var httpClient = new HttpClient(handler))
            {
                using (var request = new HttpRequestMessage(new HttpMethod("GET"), "https://kubernetes.default.svc/api/v1/namespaces/default/services/internal-demoapp/"))
                {
                    request.Headers.TryAddWithoutValidation("Authorization", $"Bearer {token}");

                    var response = await httpClient.SendAsync(request);
                    string stringResponse = await response.Content.ReadAsStringAsync();

                    try
                    {
                        dynamic jsonResponse = JsonConvert.DeserializeObject(stringResponse);
                        string ip = jsonResponse.status.loadBalancer.ingress[0].ip;
                        sb.AppendLine($"{"Service Private IP: ",-50} | {ip}");
                        stringResponse = ip;
                    }
                    catch (Exception ex)
                    {
                        sb.AppendLine("------Exception calling K8s API server ------");
                        sb.AppendLine(ex.Message);
                        sb.AppendLine("-----------stringResponse--------------------");
                        sb.AppendLine(stringResponse);
                    }

                    return stringResponse;
                }
            }
        }

    }
}
