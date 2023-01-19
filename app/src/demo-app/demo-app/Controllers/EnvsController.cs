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

            string j = "{\"kind\":\"Service\",\"apiVersion\":\"v1\",\"metadata\":{\"name\":\"internal-demoapp\",\"namespace\":\"default\",\"uid\":\"659c054f-4323-4a39-b2e9-dac568a6e40c\",\"resourceVersion\":\"862097\",\"creationTimestamp\":\"2023-01-19T01:58:18Z\",\"annotations\":{\"kubectl.kubernetes.io/last-applied-configuration\":\"{\\\"apiVersion\\\":\\\"v1\\\",\\\"kind\\\":\\\"Service\\\",\\\"metadata\\\":{\\\"annotations\\\":{\\\"service.beta.kubernetes.io/azure-load-balancer-internal\\\":\\\"true\\\"},\\\"name\\\":\\\"internal-demoapp\\\",\\\"namespace\\\":\\\"default\\\"},\\\"spec\\\":{\\\"ports\\\":[{\\\"port\\\":8080,\\\"protocol\\\":\\\"TCP\\\",\\\"targetPort\\\":80}],\\\"selector\\\":{\\\"app\\\":\\\"demoapp\\\"},\\\"type\\\":\\\"LoadBalancer\\\"}}\\n\",\"service.beta.kubernetes.io/azure-load-balancer-internal\":\"true\"},\"finalizers\":[\"service.kubernetes.io/load-balancer-cleanup\"],\"managedFields\":[{\"manager\":\"kubectl-client-side-apply\",\"operation\":\"Update\",\"apiVersion\":\"v1\",\"time\":\"2023-01-19T01:58:18Z\",\"fieldsType\":\"FieldsV1\",\"fieldsV1\":{\"f:metadata\":{\"f:annotations\":{\".\":{},\"f:kubectl.kubernetes.io/last-applied-configuration\":{},\"f:service.beta.kubernetes.io/azure-load-balancer-internal\":{}}},\"f:spec\":{\"f:allocateLoadBalancerNodePorts\":{},\"f:externalTrafficPolicy\":{},\"f:internalTrafficPolicy\":{},\"f:ports\":{\".\":{},\"k:{\\\"port\\\":8080,\\\"protocol\\\":\\\"TCP\\\"}\":{\".\":{},\"f:port\":{},\"f:protocol\":{},\"f:targetPort\":{}}},\"f:selector\":{},\"f:sessionAffinity\":{},\"f:type\":{}}}},{\"manager\":\"cloud-controller-manager\",\"operation\":\"Update\",\"apiVersion\":\"v1\",\"time\":\"2023-01-19T01:58:43Z\",\"fieldsType\":\"FieldsV1\",\"fieldsV1\":{\"f:metadata\":{\"f:finalizers\":{\".\":{},\"v:\\\"service.kubernetes.io/load-balancer-cleanup\\\"\":{}}},\"f:status\":{\"f:loadBalancer\":{\"f:ingress\":{}}}},\"subresource\":\"status\"}]},\"spec\":{\"ports\":[{\"protocol\":\"TCP\",\"port\":8080,\"targetPort\":80,\"nodePort\":30319}],\"selector\":{\"app\":\"demoapp\"},\"clusterIP\":\"10.0.224.209\",\"clusterIPs\":[\"10.0.224.209\"],\"type\":\"LoadBalancer\",\"sessionAffinity\":\"None\",\"externalTrafficPolicy\":\"Cluster\",\"ipFamilies\":[\"IPv4\"],\"ipFamilyPolicy\":\"SingleStack\",\"allocateLoadBalancerNodePorts\":true,\"internalTrafficPolicy\":\"Cluster\"},\"status\":{\"loadBalancer\":{\"ingress\":[{\"ip\":\"10.220.4.5\"}]}}}";
            dynamic jsonj = JsonConvert.DeserializeObject(j);
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
