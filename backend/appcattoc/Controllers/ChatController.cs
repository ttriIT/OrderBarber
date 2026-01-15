using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using appcattoc.DTOs.Chat;
using appcattoc.Services;
using System.Security.Claims;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;

    public ChatController(IChatService chatService)
    {
        _chatService = chatService;
    }
    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: CREATE CHAT SESSION                                     ║
    // ║ POST /api/chat/sessions                                        ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Create a new chat session
    /// </summary>
    [HttpPost("sessions")]
    public async Task<ActionResult<ChatSessionResponse>> CreateSession([FromBody] CreateChatSessionRequest request)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _chatService.CreateChatSessionAsync(userId, request);

        if (!result.Success)
        {
            return BadRequest(new { message = result.Message });
        }

        return Ok(result.Data);
    }
    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: SEND MESSAGE                                            ║
    // ║ POST /api/chat/messages                                        ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Send a message in a chat session
    /// </summary>
    [HttpPost("messages")]
    public async Task<ActionResult<ChatMessageResponse>> SendMessage([FromBody] SendMessageRequest request)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _chatService.SendMessageAsync(userId, request);

        if (!result.Success)
        {
            return BadRequest(new { message = result.Message });
        }

        return Ok(result.Data);
    }

    /// <summary>
    /// Get all chat sessions for the current user
    /// </summary>
    [HttpGet("sessions")]
    public async Task<ActionResult<List<ChatSessionResponse>>> GetSessions()
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var sessions = await _chatService.GetUserChatSessionsAsync(userId);
        return Ok(sessions);
    }

    /// <summary>
    /// Get all messages in a chat session
    /// </summary>
    [HttpGet("sessions/{sessionId}/messages")]
    public async Task<ActionResult<List<ChatMessageResponse>>> GetMessages(int sessionId)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var messages = await _chatService.GetSessionMessagesAsync(sessionId, userId);
        return Ok(messages);
    }
}
