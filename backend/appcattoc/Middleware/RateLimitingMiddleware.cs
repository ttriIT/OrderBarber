using System.Collections.Concurrent;
using System.Net;

namespace appcattoc.Middleware;

/// <summary>
/// Rate limiting middleware to prevent brute-force attacks on authentication endpoints
/// </summary>
public class RateLimitingMiddleware
{
    private readonly RequestDelegate _next;
    private static readonly ConcurrentDictionary<string, RequestCounter> _requests = new();
    private readonly int _maxRequests;
    private readonly TimeSpan _timeWindow;
    private static readonly Timer _cleanupTimer;

    static RateLimitingMiddleware()
    {
        // 🔧 MEMORY LEAK FIX: Periodic cleanup every 5 minutes
        _cleanupTimer = new Timer(CleanupOldEntries, null, TimeSpan.FromMinutes(5), TimeSpan.FromMinutes(5));
    }

    public RateLimitingMiddleware(RequestDelegate next, int maxRequests = 5, int timeWindowSeconds = 60)
    {
        _next = next;
        _maxRequests = maxRequests;
        _timeWindow = TimeSpan.FromSeconds(timeWindowSeconds);
    }

    private static void CleanupOldEntries(object? state)
    {
        var now = DateTime.UtcNow;
        var keysToRemove = _requests
            .Where(kvp => kvp.Value.Requests.All(r => now - r > TimeSpan.FromMinutes(10)))
            .Select(kvp => kvp.Key)
            .ToList();

        foreach (var key in keysToRemove)
        {
            _requests.TryRemove(key, out _);
        }
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var endpoint = context.Request.Path.Value?.ToLower();
        
        // Only apply rate limiting to auth endpoints
        if (endpoint != null && (endpoint.Contains("/api/auth/login") || 
                                 endpoint.Contains("/api/auth/register")))
        {
            var clientId = GetClientIdentifier(context);
            var requestCounter = _requests.GetOrAdd(clientId, _ => new RequestCounter());

            bool shouldBlock = false;
            lock (requestCounter)
            {
                // Clean up old requests
                requestCounter.Requests.RemoveAll(r => DateTime.UtcNow - r > _timeWindow);

                if (requestCounter.Requests.Count >= _maxRequests)
                {
                    shouldBlock = true;
                }
                else
                {
                    requestCounter.Requests.Add(DateTime.UtcNow);
                }
            }

            if (shouldBlock)
            {
                context.Response.StatusCode = (int)HttpStatusCode.TooManyRequests;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsJsonAsync(new
                {
                    message = "Too many requests. Please try again later.",
                    retryAfter = (int)_timeWindow.TotalSeconds
                });
                return;
            }
        }

        await _next(context);
    }

    private string GetClientIdentifier(HttpContext context)
    {
        // Try to get real IP from headers (for reverse proxy scenarios)
        var forwardedFor = context.Request.Headers["X-Forwarded-For"].FirstOrDefault();
        if (!string.IsNullOrEmpty(forwardedFor))
        {
            return forwardedFor.Split(',')[0].Trim();
        }

        var realIp = context.Request.Headers["X-Real-IP"].FirstOrDefault();
        if (!string.IsNullOrEmpty(realIp))
        {
            return realIp;
        }

        // Fallback to connection remote IP
        return context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    }

    private class RequestCounter
    {
        public List<DateTime> Requests { get; set; } = new();
    }
}

/// <summary>
/// Extension method to easily add rate limiting middleware
/// </summary>
public static class RateLimitingMiddlewareExtensions
{
    public static IApplicationBuilder UseRateLimiting(this IApplicationBuilder builder, 
        int maxRequests = 5, int timeWindowSeconds = 60)
    {
        return builder.UseMiddleware<RateLimitingMiddleware>(maxRequests, timeWindowSeconds);
    }
}
