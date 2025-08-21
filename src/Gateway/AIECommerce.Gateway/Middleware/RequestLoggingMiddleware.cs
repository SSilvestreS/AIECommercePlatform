using Microsoft.Extensions.Logging;
using System.Diagnostics;

namespace AIECommerce.Gateway.Middleware;

/// <summary>
/// Middleware personalizado para logging de todas as requisições HTTP
/// Registra informações sobre requisições de entrada e saída para monitoramento
/// </summary>
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    /// <summary>
    /// Construtor do middleware
    /// </summary>
    /// <param name="next">Próximo middleware na pipeline</param>
    /// <param name="logger">Logger para registrar informações</param>
    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    /// <summary>
    /// Método principal do middleware que processa cada requisição
    /// </summary>
    /// <param name="context">Contexto HTTP da requisição</param>
    /// <returns>Task de execução assíncrona</returns>
    public async Task InvokeAsync(HttpContext context)
    {
        // Captura o timestamp de início da requisição
        var startTime = Stopwatch.StartNew();
        var requestId = Guid.NewGuid().ToString("N")[..8]; // ID único de 8 caracteres
        
        try
        {
            // Log da requisição de entrada
            _logger.LogInformation(
                "[{RequestId}] Requisição iniciada: {Method} {Path} de {IP}",
                requestId,
                context.Request.Method,
                context.Request.Path,
                GetClientIP(context)
            );

            // Processa a requisição através da pipeline
            await _next(context);

            // Calcula o tempo total de processamento
            startTime.Stop();
            var elapsedMs = startTime.ElapsedMilliseconds;

            // Log da resposta de saída
            _logger.LogInformation(
                "[{RequestId}] Requisição concluída: {Method} {Path} - Status: {StatusCode} em {ElapsedMs}ms",
                requestId,
                context.Request.Method,
                context.Request.Path,
                context.Response.StatusCode,
                elapsedMs
            );

            // Log de performance para requisições lentas
            if (elapsedMs > 1000) // Mais de 1 segundo
            {
                _logger.LogWarning(
                    "[{RequestId}] Requisição lenta detectada: {Method} {Path} levou {ElapsedMs}ms",
                    requestId,
                    context.Request.Method,
                    context.Request.Path,
                    elapsedMs
                );
            }
        }
        catch (Exception ex)
        {
            // Log de erro em caso de exceção
            startTime.Stop();
            var elapsedMs = startTime.ElapsedMilliseconds;
            
            _logger.LogError(
                ex,
                "[{RequestId}] Erro na requisição: {Method} {Path} após {ElapsedMs}ms - Erro: {ErrorMessage}",
                requestId,
                context.Request.Method,
                context.Request.Path,
                elapsedMs,
                ex.Message
            );

            // Re-lança a exceção para que outros middlewares possam tratá-la
            throw;
        }
    }

    /// <summary>
    /// Obtém o endereço IP real do cliente, considerando proxies e load balancers
    /// </summary>
    /// <param name="context">Contexto HTTP</param>
    /// <returns>Endereço IP do cliente</returns>
    private static string GetClientIP(HttpContext context)
    {
        // Verifica headers comuns de proxy
        var forwardedFor = context.Request.Headers["X-Forwarded-For"].FirstOrDefault();
        if (!string.IsNullOrEmpty(forwardedFor))
        {
            // Pega o primeiro IP da lista (cliente original)
            return forwardedFor.Split(',')[0].Trim();
        }

        var realIP = context.Request.Headers["X-Real-IP"].FirstOrDefault();
        if (!string.IsNullOrEmpty(realIP))
        {
            return realIP;
        }

        // IP direto da conexão
        return context.Connection.RemoteIpAddress?.ToString() ?? "Unknown";
    }
}
