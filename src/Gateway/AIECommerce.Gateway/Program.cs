using AIECommerce.Gateway.Middleware;
using Serilog;
using Serilog.Events;

// Configuração do logger Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .WriteTo.Console()
    .WriteTo.File("logs/gateway-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

try
{
    Log.Information("Iniciando o Gateway da AIECommerce Platform...");
    
    var builder = WebApplication.CreateBuilder(args);

    // Configuração do Serilog
    builder.Host.UseSerilog();

    // Configuração dos serviços
    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();
    
    // Configuração do Swagger/OpenAPI
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo 
        { 
            Title = "AIECommerce Gateway API", 
            Version = "v1",
            Description = "API Gateway principal da plataforma AIECommerce com funcionalidades de ML"
        });
    });

    // Configuração do CORS
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowAll", policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
    });

    // Configuração do HTTP Client com Polly para resiliência
    builder.Services.AddHttpClient();

    // Configuração de serviços customizados
    builder.Services.AddScoped<RequestLoggingMiddleware>();

    var app = builder.Build();

    // Configuração do pipeline HTTP
    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "AIECommerce Gateway API v1");
            c.RoutePrefix = string.Empty; // Swagger na raiz
        });
    }

    // Middleware de logging de requisições
    app.UseMiddleware<RequestLoggingMiddleware>();

    // Configuração do CORS
    app.UseCors("AllowAll");

    // Configuração de roteamento
    app.UseRouting();
    app.UseAuthorization();

    // Mapeamento dos controllers
    app.MapControllers();

    // Endpoint de health check
    app.MapGet("/health", () => new { Status = "OK", Timestamp = DateTime.UtcNow, Service = "AIECommerce Gateway" });

    Log.Information("Gateway iniciado com sucesso na porta {Port}", app.Urls.FirstOrDefault() ?? "não definida");
    
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Erro fatal ao iniciar o Gateway");
}
finally
{
    Log.CloseAndFlush();
}
