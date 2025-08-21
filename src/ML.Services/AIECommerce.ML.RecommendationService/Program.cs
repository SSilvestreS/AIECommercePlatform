using Serilog;
using Serilog.Events;
using AIECommerce.ML.RecommendationService.Services;

// Configuração do logger Serilog para o serviço de recomendações
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .WriteTo.Console()
    .WriteTo.File("logs/ml-recommendation-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

try
{
    Log.Information("Iniciando o Serviço de Recomendações ML da AIECommerce Platform...");
    
    var builder = WebApplication.CreateBuilder(args);

    // Configuração do Serilog
    builder.Host.UseSerilog();

    // Configuração dos serviços básicos
    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();
    
    // Configuração do Swagger/OpenAPI para documentação da API
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo 
        { 
            Title = "AIECommerce ML Recommendation Service", 
            Version = "v1",
            Description = "Serviço de Machine Learning para geração de recomendações personalizadas"
        });
    });

    // Configuração do CORS para permitir requisições de diferentes origens
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowAll", policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
    });

    // Configuração de serviços customizados para ML
    builder.Services.AddScoped<RecommendationEngine>();

    var app = builder.Build();

    // Configuração do pipeline HTTP
    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "ML Recommendation Service v1");
            c.RoutePrefix = string.Empty; // Swagger na raiz
        });
    }

    // Configuração de URLs para usar apenas HTTP em desenvolvimento
    app.Urls.Clear();
    app.Urls.Add("http://0.0.0.0:5001");

    // Configuração do CORS
    app.UseCors("AllowAll");

    // Configuração de roteamento
    app.UseRouting();
    app.UseAuthorization();

    // Mapeamento dos controllers
    app.MapControllers();

    // Endpoint de health check específico para ML
    app.MapGet("/health", () => new { 
        Status = "OK", 
        Timestamp = DateTime.UtcNow, 
        Service = "AIECommerce ML Recommendation Service",
        Version = "1.0.0",
        MLModels = "Ativos",
        LastTraining = DateTime.UtcNow.AddDays(-1)
    });

    Log.Information("Serviço de Recomendações ML iniciado com sucesso na porta {Port}", 
        app.Urls.FirstOrDefault() ?? "não definida");
    
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Erro fatal ao iniciar o Serviço de Recomendações ML");
}
finally
{
    Log.CloseAndFlush();
}
