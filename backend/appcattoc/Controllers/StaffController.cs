using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using appcattoc.DTOs.Staff;
using appcattoc.Services;
using System.Security.Claims;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Staff")]
public class StaffController : ControllerBase
{
    private readonly IStaffService _staffService;

    public StaffController(IStaffService staffService)
    {
        _staffService = staffService;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: GET STAFF SCHEDULE                                      ║
    // ║ GET /api/staff/schedule?date=YYYY-MM-DD                        ║
    // ║ Authorization: Required (Staff)                                ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get staff schedule for a specific date
    /// </summary>
    [HttpGet("schedule")]
    public async Task<ActionResult<StaffScheduleResponse>> GetSchedule([FromQuery] DateTime? date)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var staff = await _staffService.GetStaffByUserIdAsync(userId);
        
        if (staff == null)
            return BadRequest(new { message = "Staff profile not found" });
        
        var scheduleDate = date ?? DateTime.Today;
        var schedule = await _staffService.GetStaffScheduleAsync(staff.Id, scheduleDate);
        return Ok(schedule);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: UPDATE APPOINTMENT STATUS                               ║
    // ║ PUT /api/staff/appointments/{appointmentId}/status             ║
    // ║ Authorization: Required (Staff)                                ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Update appointment status (confirm/complete/cancel)
    /// </summary>
    [HttpPut("appointments/{appointmentId}/status")]
    public async Task<ActionResult> UpdateAppointmentStatus(
        int appointmentId,
        [FromBody] UpdateAppointmentStatusRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var staff = await _staffService.GetStaffByUserIdAsync(userId);
        
        if (staff == null)
            return BadRequest(new { message = "Staff profile not found" });
        
        var success = await _staffService.UpdateAppointmentStatusAsync(
            staff.Id, 
            appointmentId, 
            request.Status, 
            request.CancellationReason ?? null);

        if (!success)
            return BadRequest(new { message = "Could not update appointment status. Check appointment ID and current status." });

        return Ok(new { message = "Appointment status updated successfully" });
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 3: GET STAFF CUSTOMERS                                     ║
    // ║ GET /api/staff/customers                                       ║
    // ║ Authorization: Required (Staff)                                ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get list of customers served by this staff
    /// </summary>
    [HttpGet("customers")]
    public async Task<ActionResult<List<StaffCustomerResponse>>> GetCustomers()
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var staff = await _staffService.GetStaffByUserIdAsync(userId);
        
        if (staff == null)
            return BadRequest(new { message = "Staff profile not found" });
        
        var customers = await _staffService.GetStaffCustomersAsync(staff.Id);
        return Ok(customers);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 4: GET STAFF REVENUE                                       ║
    // ║ GET /api/staff/revenue?startDate=&endDate=                     ║
    // ║ Authorization: Required (Staff)                                ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get personal revenue statistics
    /// </summary>
    [HttpGet("revenue")]
    public async Task<ActionResult<StaffRevenueResponse>> GetRevenue(
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var staff = await _staffService.GetStaffByUserIdAsync(userId);
        
        if (staff == null)
            return BadRequest(new { message = "Staff profile not found" });
        
        var revenue = await _staffService.GetStaffRevenueAsync(staff.Id, startDate, endDate);
        return Ok(revenue);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 5: UPDATE STAFF PROFILE                                    ║
    // ║ PUT /api/staff/profile                                         ║
    // ║ Authorization: Required (Staff)                                ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Update staff profile and avatar
    /// </summary>
    [HttpPut("profile")]
    public async Task<ActionResult> UpdateProfile([FromBody] UpdateStaffProfileRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var staff = await _staffService.GetStaffByUserIdAsync(userId);
        
        if (staff == null)
            return BadRequest(new { message = "Staff profile not found" });
        
        var success = await _staffService.UpdateStaffProfileAsync(staff.Id, request);
        
        if (!success)
            return NotFound(new { message = "Staff profile not found" });

        return Ok(new { message = "Profile updated successfully" });
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 6: GET WORK HISTORY                                        ║
    // ║ GET /api/staff/history?startDate=&endDate=                     ║
    // ║ Authorization: Required (Staff)                                ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get work history (completed appointments)
    /// </summary>
    [HttpGet("history")]
    public async Task<ActionResult<List<StaffWorkHistoryResponse>>> GetWorkHistory(
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var staff = await _staffService.GetStaffByUserIdAsync(userId);
        
        if (staff == null)
            return BadRequest(new { message = "Staff profile not found" });
        
        var history = await _staffService.GetWorkHistoryAsync(staff.Id, startDate, endDate);
        return Ok(history);
    }
}
