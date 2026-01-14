using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using appcattoc.Data;
using appcattoc.Models.Entities;
using appcattoc.Models.Enums;
using appcattoc.DTOs.Staff;
using System.Security.Claims;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AppointmentsController : ControllerBase
{
    private readonly BarberDbContext _context;

    public AppointmentsController(BarberDbContext context)
    {
        _context = context;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: CREATE APPOINTMENT (CUSTOMER)                           ║
    // ║ POST /api/appointments                                         ║
    // ║ Authorization: Required (Customer)                             ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Create a new appointment (for modern Appointment system)
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Appointment>> CreateAppointment([FromBody] CreateAppointmentRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var customerId = int.Parse(userIdStr);

        // Validate staff exists and is active
        var staff = await _context.StaffProfiles
            .Include(s => s.Shop)
            .FirstOrDefaultAsync(s => s.Id == request.StaffId && s.IsActive);

        if (staff == null)
            return BadRequest(new { message = "Staff not found or inactive" });

        // Validate service exists
        var service = await _context.Services
            .FirstOrDefaultAsync(s => s.Id == request.ServiceId);

        if (service == null)
            return BadRequest(new { message = "Service not found" });

        // Calculate end time
        var endTime = request.StartTime.AddMinutes(service.DurationMinutes);

        // Check if time is within shop hours
        if (staff.Shop != null)
        {
            var appointmentTime = request.StartTime.TimeOfDay;
            if (appointmentTime < staff.Shop.OpenTime || endTime.TimeOfDay > staff.Shop.CloseTime)
            {
                return BadRequest(new { message = "Appointment time is outside shop operating hours" });
            }
        }

        // Check for overlapping appointments
        var hasOverlap = await _context.Appointments
            .AnyAsync(a => a.StaffId == request.StaffId &&
                          a.Status != AppointmentStatus.Cancelled &&
                          a.Status != AppointmentStatus.NoShow &&
                          ((request.StartTime >= a.StartTime && request.StartTime < a.EndTime) ||
                           (endTime > a.StartTime && endTime <= a.EndTime) ||
                           (request.StartTime <= a.StartTime && endTime >= a.EndTime)));

        if (hasOverlap)
            return BadRequest(new { message = "Staff is not available at the requested time" });

        // Create appointment
        var appointment = new Appointment
        {
            CustomerId = customerId,
            StaffId = request.StaffId,
            ServiceId = request.ServiceId,
            StartTime = request.StartTime,
            EndTime = endTime,
            Status = AppointmentStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };

        _context.Appointments.Add(appointment);
        await _context.SaveChangesAsync();

        // Load navigation properties for response
        await _context.Entry(appointment).Reference(a => a.Customer).LoadAsync();
        await _context.Entry(appointment).Reference(a => a.Staff).LoadAsync();
        await _context.Entry(appointment).Reference(a => a.Service).LoadAsync();

        return CreatedAtAction(nameof(GetAppointment), new { id = appointment.Id }, appointment);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: GET MY APPOINTMENTS                                     ║
    // ║ GET /api/appointments/my                                       ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get appointments for current user
    /// </summary>
    [HttpGet("my")]
    public async Task<ActionResult<List<object>>> GetMyAppointments(
        [FromQuery] string? status = null,
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var role = User.FindFirst(ClaimTypes.Role)?.Value;

        var query = _context.Appointments
            .Include(a => a.Customer)
            .Include(a => a.Staff)
                .ThenInclude(s => s.User)
            .Include(a => a.Service)
            .AsQueryable();

        // Filter by role
        if (role == "Customer")
        {
            query = query.Where(a => a.CustomerId == userId);
        }
        else if (role == "Staff")
        {
            var staff = await _context.StaffProfiles.FirstOrDefaultAsync(s => s.UserId == userId);
            if (staff != null)
            {
                query = query.Where(a => a.StaffId == staff.Id);
            }
        }

        // Filter by status
        if (!string.IsNullOrEmpty(status) && Enum.TryParse<AppointmentStatus>(status, true, out var statusEnum))
        {
            query = query.Where(a => a.Status == statusEnum);
        }

        // Filter by date range
        if (startDate.HasValue)
        {
            query = query.Where(a => a.StartTime >= startDate.Value);
        }
        if (endDate.HasValue)
        {
            query = query.Where(a => a.StartTime <= endDate.Value);
        }

        var appointments = await query
            .OrderByDescending(a => a.StartTime)
            .Select(a => new
            {
                Id = a.Id,
                CustomerId = a.CustomerId,
                CustomerName = a.Customer.FullName,
                StaffId = a.StaffId,
                StaffName = a.Staff.User.FullName,
                ServiceId = a.ServiceId,
                ServiceName = a.Service.Name,
                ServicePrice = a.Service.Price,
                StartTime = a.StartTime,
                EndTime = a.EndTime,
                Status = a.Status.ToString(),
                CreatedAt = a.CreatedAt
            })
            .ToListAsync();

        return Ok(appointments);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 3: GET APPOINTMENT BY ID                                   ║
    // ║ GET /api/appointments/{id}                                     ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get appointment details by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<object>> GetAppointment(int id)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var role = User.FindFirst(ClaimTypes.Role)?.Value;

        var appointment = await _context.Appointments
            .Include(a => a.Customer)
            .Include(a => a.Staff)
                .ThenInclude(s => s.User)
            .Include(a => a.Service)
            .FirstOrDefaultAsync(a => a.Id == id);

        if (appointment == null)
            return NotFound(new { message = "Appointment not found" });

        // Check authorization
        if (role == "Customer" && appointment.CustomerId != userId)
            return Forbid();

        if (role == "Staff")
        {
            var staff = await _context.StaffProfiles.FirstOrDefaultAsync(s => s.UserId == userId);
            if (staff == null || appointment.StaffId != staff.Id)
                return Forbid();
        }

        return Ok(new
        {
            Id = appointment.Id,
            CustomerId = appointment.CustomerId,
            CustomerName = appointment.Customer.FullName,
            CustomerPhone = appointment.Customer.Phone,
            StaffId = appointment.StaffId,
            StaffName = appointment.Staff.User.FullName,
            ServiceId = appointment.ServiceId,
            ServiceName = appointment.Service.Name,
            ServicePrice = appointment.Service.Price,
            ServiceDuration = appointment.Service.DurationMinutes,
            StartTime = appointment.StartTime,
            EndTime = appointment.EndTime,
            Status = appointment.Status.ToString(),
            CreatedAt = appointment.CreatedAt,
            UpdatedAt = appointment.UpdatedAt
        });
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 4: CANCEL APPOINTMENT                                      ║
    // ║ PUT /api/appointments/{id}/cancel                              ║
    // ║ Authorization: Required (Customer)                             ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Cancel an appointment (Customer only)
    /// </summary>
    [HttpPut("{id}/cancel")]
    public async Task<ActionResult> CancelAppointment(int id)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var customerId = int.Parse(userIdStr);

        var appointment = await _context.Appointments
            .FirstOrDefaultAsync(a => a.Id == id && a.CustomerId == customerId);

        if (appointment == null)
            return NotFound(new { message = "Appointment not found or you don't have permission" });

        // Only allow cancellation for Pending or Confirmed appointments
        if (appointment.Status != AppointmentStatus.Pending && 
            appointment.Status != AppointmentStatus.Confirmed)
        {
            return BadRequest(new { message = $"Cannot cancel appointment with status: {appointment.Status}" });
        }

        appointment.Status = AppointmentStatus.Cancelled;
        appointment.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Appointment cancelled successfully" });
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 5: UPDATE APPOINTMENT STATUS (STAFF/ADMIN)                 ║
    // ║ PUT /api/appointments/{id}/status                              ║
    // ║ Authorization: Required (Staff, Admin)                         ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Update appointment status (Staff can confirm/complete, Admin can do anything)
    /// </summary>
    [HttpPut("{id}/status")]
    [Authorize(Roles = "Staff,Admin")]
    public async Task<ActionResult> UpdateAppointmentStatus(
        int id,
        [FromBody] UpdateAppointmentStatusRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var role = User.FindFirst(ClaimTypes.Role)?.Value;

        var appointment = await _context.Appointments.FindAsync(id);
        if (appointment == null)
            return NotFound(new { message = "Appointment not found" });

        // If Staff, verify they own this appointment
        if (role == "Staff")
        {
            var staff = await _context.StaffProfiles.FirstOrDefaultAsync(s => s.UserId == userId);
            if (staff == null || appointment.StaffId != staff.Id)
                return Forbid();
        }

        // Parse and validate status
        if (!Enum.TryParse<AppointmentStatus>(request.Status, true, out var newStatus))
        {
            return BadRequest(new { message = "Invalid status value" });
        }

        // Validate status transitions
        var validTransition = (appointment.Status, newStatus) switch
        {
            (AppointmentStatus.Pending, AppointmentStatus.Confirmed) => true,
            (AppointmentStatus.Confirmed, AppointmentStatus.Completed) => true,
            (AppointmentStatus.Pending, AppointmentStatus.Cancelled) => true,
            (AppointmentStatus.Confirmed, AppointmentStatus.Cancelled) => true,
            (AppointmentStatus.Confirmed, AppointmentStatus.NoShow) => true,
            _ when role == "Admin" => true, // Admin can do any transition
            _ => false
        };

        if (!validTransition)
        {
            return BadRequest(new { message = $"Cannot transition from {appointment.Status} to {newStatus}" });
        }

        appointment.Status = newStatus;
        appointment.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Appointment status updated successfully", status = newStatus.ToString() });
    }
}

public class CreateAppointmentRequest
{
    public required int StaffId { get; set; }
    public required int ServiceId { get; set; }
    public required DateTime StartTime { get; set; }
}
