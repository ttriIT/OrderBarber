using Microsoft.EntityFrameworkCore;
using appcattoc.Data;
using appcattoc.DTOs.Chat;
using Entities = appcattoc.Models.Entities;
using System.Text;
using System.Net.Http.Headers;
using System.Text.Json;

namespace appcattoc.Services;

public interface IChatService
{
    Task<ServiceResult<ChatSessionResponse>> CreateChatSessionAsync(int userId, CreateChatSessionRequest request);
    Task<ServiceResult<ChatMessageResponse>> SendMessageAsync(int userId, SendMessageRequest request);
    Task<List<ChatSessionResponse>> GetUserChatSessionsAsync(int userId);
    Task<List<ChatMessageResponse>> GetSessionMessagesAsync(int sessionId, int userId);
}

public class ChatService : IChatService
{
    private readonly BarberDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly HttpClient _httpClient;
    private readonly string _geminiApiKey;

    public ChatService(BarberDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
        _geminiApiKey = _configuration["Gemini:ApiKey"] ?? throw new Exception("Gemini API Key not found");
        _httpClient = new HttpClient();
    }

    public async Task<ServiceResult<ChatSessionResponse>> CreateChatSessionAsync(int userId, CreateChatSessionRequest request)
    {
        try
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return ServiceResult<ChatSessionResponse>.Failure("User not found");
            }

            var session = new Entities.ChatSession
            {
                User1_Id = userId,
                User2_Id = null,
                Type = request.SessionType,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.ChatSessions.Add(session);
            await _context.SaveChangesAsync();

            var response = new ChatSessionResponse
            {
                SessionId = session.Id,
                UserId = userId,
                SessionType = session.Type,
                Title = request.Title ?? "New Chat",
                CreatedAt = session.CreatedAt,
                UpdatedAt = session.UpdatedAt ?? session.CreatedAt,
                Messages = new List<ChatMessageResponse>()
            };

            return ServiceResult<ChatSessionResponse>.SuccessResult(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<ChatSessionResponse>.Failure($"Error creating chat session: {ex.Message}");
        }
    }

    public async Task<ServiceResult<ChatMessageResponse>> SendMessageAsync(int userId, SendMessageRequest request)
    {
        try
        {
            var session = await _context.ChatSessions
                .Include(s => s.Messages)
                .FirstOrDefaultAsync(s => s.Id == request.SessionId && s.User1_Id == userId);

            if (session == null)
            {
                return ServiceResult<ChatMessageResponse>.Failure("Chat session not found or access denied");
            }

            var userMessage = new Entities.ChatMessage
            {
                SessionId = request.SessionId,
                SenderId = userId,
                Content = request.Content,
                IsAI = false,
                CreatedAt = DateTime.UtcNow
            };

            _context.ChatMessages.Add(userMessage);
            await _context.SaveChangesAsync();

            var aiResponse = await GetGeminiResponseAsync(request.Content, session.Messages.ToList());

            var aiMessage = new Entities.ChatMessage
            {
                SessionId = request.SessionId,
                SenderId = null,
                Content = aiResponse,
                IsAI = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.ChatMessages.Add(aiMessage);
            session.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var response = new ChatMessageResponse
            {
                MessageId = aiMessage.Id,
                SessionId = aiMessage.SessionId,
                SenderId = aiMessage.SenderId,
                SenderName = "AI Assistant",
                Content = aiMessage.Content,
                CreatedAt = aiMessage.CreatedAt
            };

            return ServiceResult<ChatMessageResponse>.SuccessResult(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<ChatMessageResponse>.Failure($"Error sending message: {ex.Message}");
        }
    }

    public async Task<List<ChatSessionResponse>> GetUserChatSessionsAsync(int userId)
    {
        var sessions = await _context.ChatSessions
            .Include(s => s.Messages.OrderByDescending(m => m.CreatedAt).Take(1))
            .Where(s => s.User1_Id == userId)
            .OrderByDescending(s => s.UpdatedAt)
            .ToListAsync();

        return sessions.Select(s => new ChatSessionResponse
        {
            SessionId = s.Id,
            UserId = userId,
            SessionType = s.Type,
            Title = "AI Chat",
            CreatedAt = s.CreatedAt,
            UpdatedAt = s.UpdatedAt ?? s.CreatedAt,
            LastMessage = s.Messages.FirstOrDefault()?.Content,
            Messages = new List<ChatMessageResponse>()
        }).ToList();
    }

    public async Task<List<ChatMessageResponse>> GetSessionMessagesAsync(int sessionId, int userId)
    {
        var sessionExists = await _context.ChatSessions
            .AnyAsync(s => s.Id == sessionId && s.User1_Id == userId);

        if (!sessionExists)
        {
            return new List<ChatMessageResponse>();
        }

        var messages = await _context.ChatMessages
            .Include(m => m.Sender)
            .Where(m => m.SessionId == sessionId)
            .OrderBy(m => m.CreatedAt)
            .ToListAsync();

        return messages.Select(m => new ChatMessageResponse
        {
            MessageId = m.Id,
            SessionId = m.SessionId,
            SenderId = m.SenderId,
            SenderName = m.SenderId == null ? "AI Assistant" : m.Sender?.FullName ?? "User",
            Content = m.Content,
            CreatedAt = m.CreatedAt
        }).ToList();
    }

    private async Task<string> GetGeminiResponseAsync(string userMessage, List<Entities.ChatMessage> conversationHistory)
    {
        try
        {
            var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key={_geminiApiKey}";
            
            var systemInstruction = "B?n là tr? lý AI cho h? th?ng ??t l?ch c?t tóc Smart Barber Booking. T? v?n d?ch v? c?t tóc, h??ng d?n ??t l?ch, gi?i ?áp th?c m?c. Tr? l?i b?ng ti?ng Vi?t, thân thi?n và chuyên nghi?p.";

            var contents = new List<object>();
            
            foreach (var msg in conversationHistory.TakeLast(10))
            {
                var role = msg.IsAI ? "model" : "user";
                contents.Add(new
                {
                    role = role,
                    parts = new[] { new { text = msg.Content } }
                });
            }

            contents.Add(new
            {
                role = "user",
                parts = new[] { new { text = userMessage } }
            });

            var requestBody = new
            {
                contents = contents,
                systemInstruction = new
                {
                    parts = new[] { new { text = systemInstruction } }
                }
            };

            var jsonContent = JsonSerializer.Serialize(requestBody);
            var httpContent = new StringContent(jsonContent, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync(url, httpContent);
            var responseContent = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                return $"Xin l?i, h? th?ng AI ?ang g?p s? c?. Vui lòng th? l?i sau.";
            }

            var jsonResponse = JsonDocument.Parse(responseContent);
            var text = jsonResponse.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString();

            return text ?? "Xin l?i, tôi không th? tr? l?i lúc này.";
        }
        catch (Exception ex)
        {
            return $"Xin l?i, h? th?ng AI ?ang g?p s? c?. (L?i: {ex.Message})";
        }
    }
}

public class ServiceResult<T>
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
    public static ServiceResult<T> SuccessResult(T data)
    {
        return new ServiceResult<T> { Success = true, Data = data, Message = "Success" };
    }
    public static ServiceResult<T> Failure(string message)
    {
        return new ServiceResult<T> { Success = false, Message = message };
    }
}

