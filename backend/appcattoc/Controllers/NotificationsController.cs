using appcattoc.DTOs.Notifications;
using appcattoc.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationsController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: GET USER NOTIFICATIONS                                  ║
    // ║ GET /api/notifications                                         ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get current user notifications
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<NotificationResponse>>> GetNotifications()
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();

        var userId = int.Parse(userIdStr);
        var notifications = await _notificationService.GetUserNotificationsAsync(userId);
        return Ok(notifications);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: MARK NOTIFICATION AS READ                               ║
    // ║ PUT /api/notifications/{id}/read                               ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Mark notification as read
    /// </summary>
    [HttpPut("{id}/read")]
    public async Task<ActionResult> MarkAsRead(int id)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();

        var userId = int.Parse(userIdStr);
        var success = await _notificationService.MarkAsReadAsync(userId, id);

        if (!success) return NotFound();
        return Ok();
    }
}
