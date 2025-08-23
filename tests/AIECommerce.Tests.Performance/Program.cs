using NBomber.Contracts;
using NBomber.CSharp;
using NBomber.Http.CSharp;
using NBomber.Plugins.Http.CSharp;
using NBomber.Plugins.Network.Ping;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Polly;
using Polly.Extensions.Http;
using System.Text.Json;

namespace AIECommerce.Tests.Performance;

public class Program
{
    private static IConfiguration _configuration = null!;
    private static ILogger<Program> _logger = null!;
    private static HttpClient _httpClient = null!;

    public static async Task Main(string[] args)
    {
        // Setup configuration
        _configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false)
            .AddEnvironmentVariables()
            .Build();

        // Setup logging
        var services = new ServiceCollection();
        services.AddLogging(builder =>
        {
            builder.AddConsole();
            builder.SetMinimumLevel(LogLevel.Information);
        });

        var serviceProvider = services.BuildServiceProvider();
        _logger = serviceProvider.GetRequiredService<ILogger<Program>>();

        // Setup HTTP client with resilience policies
        _httpClient = CreateResilientHttpClient();

        _logger.LogInformation("🚀 Starting AIECommerce Platform Performance Tests");

        try
        {
            // Run all performance test scenarios
            await RunGatewayPerformanceTests();
            await RunMLServicePerformanceTests();
            await RunDatabasePerformanceTests();
            await RunLoadBalancingTests();
            await RunStressTests();

            _logger.LogInformation("✅ All performance tests completed successfully!");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ Performance tests failed");
            Environment.Exit(1);
        }
    }

    private static HttpClient CreateResilientHttpClient()
    {
        var retryPolicy = HttpPolicyExtensions
            .HandleTransientHttpError()
            .WaitAndRetryAsync(3, retryAttempt => 
                TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));

        var circuitBreakerPolicy = HttpPolicyExtensions
            .HandleTransientHttpError()
            .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));

        var timeoutPolicy = Policy.TimeoutAsync<HttpResponseMessage>(30);

        var combinedPolicy = Policy.WrapAsync(retryPolicy, circuitBreakerPolicy, timeoutPolicy);

        var handler = new HttpClientHandler();
        var client = new HttpClient(handler);
        client.Timeout = TimeSpan.FromSeconds(60);

        return client;
    }

    private static async Task RunGatewayPerformanceTests()
    {
        _logger.LogInformation("🔍 Running Gateway Performance Tests");

        var gatewayUrl = _configuration["Gateway:BaseUrl"] ?? "http://localhost:5000";

        var healthCheckScenario = Scenario.Create("gateway_health_check", async context =>
        {
            var response = await _httpClient.GetAsync($"{gatewayUrl}/health");
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.RampUp(copies: 100, during: TimeSpan.FromMinutes(2)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(30))
        .WithMaxFailCount(100);

        var recommendationsScenario = Scenario.Create("gateway_recommendations", async context =>
        {
            var userId = Random.Shared.Next(1, 1000);
            var response = await _httpClient.GetAsync($"{gatewayUrl}/api/gateway/recommendations?userId={userId}");
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.RampUp(copies: 200, during: TimeSpan.FromMinutes(3)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(30))
        .WithMaxFailCount(200);

        NBomberRunner
            .RegisterScenarios(healthCheckScenario, recommendationsScenario)
            .WithTestName("Gateway Performance Test")
            .WithTestSuite("API Gateway")
            .Run();
    }

    private static async Task RunMLServicePerformanceTests()
    {
        _logger.LogInformation("🧠 Running ML Service Performance Tests");

        var mlServiceUrl = _configuration["MLService:BaseUrl"] ?? "http://localhost:5002";

        var mlRecommendationsScenario = Scenario.Create("ml_recommendations", async context =>
        {
            var userId = Random.Shared.Next(1, 1000);
            var response = await _httpClient.GetAsync($"{mlServiceUrl}/api/recommendations/user/{userId}");
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.RampUp(copies: 150, during: TimeSpan.FromMinutes(2)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(30))
        .WithMaxFailCount(150);

        var mlModelRetrainScenario = Scenario.Create("ml_model_retrain", async context =>
        {
            var response = await _httpClient.PostAsync($"{mlServiceUrl}/api/recommendations/model/retrain", null);
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.RampUp(copies: 50, during: TimeSpan.FromMinutes(1)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(30))
        .WithMaxFailCount(50);

        NBomberRunner
            .RegisterScenarios(mlRecommendationsScenario, mlModelRetrainScenario)
            .WithTestName("ML Service Performance Test")
            .WithTestSuite("Machine Learning Services")
            .Run();
    }

    private static async Task RunDatabasePerformanceTests()
    {
        _logger.LogInformation("🗄️ Running Database Performance Tests");

        var gatewayUrl = _configuration["Gateway:BaseUrl"] ?? "http://localhost:5000";

        var databaseReadScenario = Scenario.Create("database_read", async context =>
        {
            var response = await _httpClient.GetAsync($"{gatewayUrl}/api/gateway/dashboard");
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.RampUp(copies: 300, during: TimeSpan.FromMinutes(3)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(30))
        .WithMaxFailCount(300);

        var databaseWriteScenario = Scenario.Create("database_write", async context =>
        {
            var reviewData = new
            {
                ProductId = Random.Shared.Next(1, 1000),
                UserId = Random.Shared.Next(1, 1000),
                Rating = Random.Shared.Next(1, 6),
                Comment = $"Performance test review {DateTime.UtcNow:yyyyMMddHHmmss}"
            };

            var content = new StringContent(JsonSerializer.Serialize(reviewData), System.Text.Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync($"{gatewayUrl}/api/gateway/reviews", content);
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.RampUp(copies: 100, during: TimeSpan.FromMinutes(2)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(30))
        .WithMaxFailCount(100);

        NBomberRunner
            .RegisterScenarios(databaseReadScenario, databaseWriteScenario)
            .WithTestName("Database Performance Test")
            .WithTestSuite("Data Persistence")
            .Run();
    }

    private static async Task RunLoadBalancingTests()
    {
        _logger.LogInformation("⚖️ Running Load Balancing Tests");

        var gatewayUrl = _configuration["Gateway:BaseUrl"] ?? "http://localhost:5000";

        var loadBalancingScenario = Scenario.Create("load_balancing", async context =>
        {
            var response = await _httpClient.GetAsync($"{gatewayUrl}/health");
            
            // Extract server info from response headers if available
            var serverInfo = response.Headers.Contains("X-Server-Info") 
                ? response.Headers.GetValues("X-Server-Info").FirstOrDefault() 
                : "unknown";
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode, payload: serverInfo)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.RampUp(copies: 500, during: TimeSpan.FromMinutes(5)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(30))
        .WithMaxFailCount(500);

        NBomberRunner
            .RegisterScenarios(loadBalancingScenario)
            .WithTestName("Load Balancing Test")
            .WithTestSuite("Scalability")
            .Run();
    }

    private static async Task RunStressTests()
    {
        _logger.LogInformation("💥 Running Stress Tests");

        var gatewayUrl = _configuration["Gateway:BaseUrl"] ?? "http://localhost:5000";

        var stressTestScenario = Scenario.Create("stress_test", async context =>
        {
            var response = await _httpClient.GetAsync($"{gatewayUrl}/health");
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.Stress(copies: 1000, during: TimeSpan.FromMinutes(10)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(60))
        .WithMaxFailCount(1000);

        var spikeTestScenario = Scenario.Create("spike_test", async context =>
        {
            var response = await _httpClient.GetAsync($"{gatewayUrl}/health");
            
            return response.IsSuccessStatusCode
                ? Response.Ok(statusCode: (int)response.StatusCode)
                : Response.Fail(statusCode: (int)response.StatusCode);
        })
        .WithLoadSimulation(Simulation.Spike(copies: 2000, during: TimeSpan.FromMinutes(2)))
        .WithWarmUpDuration(TimeSpan.FromSeconds(30))
        .WithMaxFailCount(2000);

        NBomberRunner
            .RegisterScenarios(stressTestScenario, spikeTestScenario)
            .WithTestName("Stress Test")
            .WithTestSuite("Reliability")
            .Run();
    }
}
