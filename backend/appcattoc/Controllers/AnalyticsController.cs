using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using appcattoc.DTOs.Analytics;
using appcattoc.Services;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "ShopManager,Admin")]
public class AnalyticsController : ControllerBase
{
    private readonly IAnalyticsService _analyticsService;

    public AnalyticsController(IAnalyticsService analyticsService)
    {
        _analyticsService = analyticsService;
    }

    /// <summary>
    /// Get revenue analytics for a specific month
    /// </summary>
    [HttpGet("revenue")]
    public async Task<ActionResult<RevenueAnalyticsResponse>> GetRevenue([FromQuery] RevenueAnalyticsRequest request)
    {
        if (request.Month < 1 || request.Month > 12)
        {
            return BadRequest(new { message = "Invalid month" });
        }

        var analytics = await _analyticsService.GetRevenueAnalyticsAsync(request);
        return Ok(analytics);
    }
    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: GET STAFF PERFORMANCE                                   ║
    // ║ GET /api/analytics/performance?shopId=&startDate=&endDate=     ║
    // ║ Authorization: Required (ShopManager, Admin)                   ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get staff performance metrics
    /// </summary>
    [HttpGet("performance")]
    public async Task<ActionResult<List<StaffPerformanceResponse>>> GetPerformance(
        [FromQuery] int shopId,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        var performance = await _analyticsService.GetStaffPerformanceAsync(shopId, startDate, endDate);
        return Ok(performance);
    }
}
