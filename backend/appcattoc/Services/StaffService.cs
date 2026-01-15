using Microsoft.EntityFrameworkCore;
using appcattoc.Data;
using appcattoc.DTOs.Staff;
using appcattoc.Models.Enums;

namespace appcattoc.Services;

public interface IStaffService
{
    Task<StaffProfileDto?> GetStaffByUserIdAsync(int userId);
    Task<StaffScheduleResponse> GetStaffScheduleAsync(int staffId, DateTime date);
    Task<bool> UpdateAppointmentStatusAsync(int staffId, int appointmentId, string status, string? cancellationReason);
    Task<List<StaffCustomerResponse>> GetStaffCustomersAsync(int staffId);
    Task<StaffRevenueResponse> GetStaffRevenueAsync(int staffId, DateTime? startDate, DateTime? endDate);
    Task<bool> UpdateStaffProfileAsync(int staffId, UpdateStaffProfileRequest request);
    Task<List<StaffWorkHistoryResponse>> GetWorkHistoryAsync(int staffId, DateTime? startDate, DateTime? endDate);
}

public class StaffProfileDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
}

public class StaffService : IStaffService
{
    private readonly BarberDbContext _context;

    public StaffService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<StaffProfileDto?> GetStaffByUserIdAsync(int userId)
    {
        var staff = await _context.StaffProfiles
            .FirstOrDefaultAsync(s => s.UserId == userId);
        
        if (staff == null)
            return null;
        
        return new StaffProfileDto
        {
            Id = staff.Id,
            UserId = staff.UserId
        };
    }

    public async Task<StaffScheduleResponse> GetStaffScheduleAsync(int staffId, DateTime date)
    {
        var staff = await _context.StaffProfiles
            .Include(s => s.Shop)
            .FirstOrDefaultAsync(s => s.Id == staffId);

        if (staff == null)
        {
            return new StaffScheduleResponse { Date = date, Slots = new List<ScheduleSlot>() };
        }

        // 🔒 NULL CHECK FIX: Validate Shop exists
        if (staff.Shop == null)
        {
            return new StaffScheduleResponse { Date = date, Slots = new List<ScheduleSlot>() };
        }

        var startOfDay = date.Date;
        var endOfDay = date.Date.AddDays(1);

        var appointments = await _context.Appointments
            .Where(a => a.StaffId == staffId &&
                       a.StartTime >= startOfDay &&
                       a.StartTime < endOfDay &&
                       a.Status != AppointmentStatus.Cancelled &&
                       a.Status != AppointmentStatus.NoShow)
            .Include(a => a.Customer)
            .Include(a => a.Service)
            .OrderBy(a => a.StartTime)
            .ToListAsync();

        var slots = new List<ScheduleSlot>();
        var shopOpenTime = startOfDay.Add(staff.Shop.OpenTime);
        var shopCloseTime = startOfDay.Add(staff.Shop.CloseTime);
        var currentTime = shopOpenTime;

        foreach (var appointment in appointments)
        {
            // Add free slot before appointment if there's a gap
            if (currentTime < appointment.StartTime)
            {
                slots.Add(new ScheduleSlot
                {
                    StartTime = currentTime,
                    EndTime = appointment.StartTime,
                    IsBooked = false
                });
            }

            // Add booked slot for appointment
            slots.Add(new ScheduleSlot
            {
                StartTime = appointment.StartTime,
                EndTime = appointment.EndTime,
                IsBooked = true,
                AppointmentId = appointment.Id,
                CustomerName = appointment.Customer?.FullName ?? "Unknown",
                ServiceName = appointment.Service?.Name ?? "Unknown"
            });

            currentTime = appointment.EndTime;
        }

        // Add final free slot if there's time remaining before closing
        if (currentTime < shopCloseTime)
        {
            slots.Add(new ScheduleSlot
            {
                StartTime = currentTime,
                EndTime = shopCloseTime,
                IsBooked = false
            });
        }

        return new StaffScheduleResponse
        {
            Date = date,
            Slots = slots
        };
    }

    public async Task<bool> UpdateAppointmentStatusAsync(int staffId, int appointmentId, string status, string? cancellationReason)
    {
        var appointment = await _context.Appointments
            .FirstOrDefaultAsync(a => a.Id == appointmentId && a.StaffId == staffId);

        if (appointment == null)
            return false;

        // Validate status transition
        switch (status.ToLower())
        {
            case "confirmed":
                if (appointment.Status != AppointmentStatus.Pending)
                    return false;
                appointment.Status = AppointmentStatus.Confirmed;
                break;

            case "completed":
                if (appointment.Status != AppointmentStatus.Confirmed)
                    return false;
                appointment.Status = AppointmentStatus.Completed;
                break;

            case "cancelled":
                appointment.Status = AppointmentStatus.Cancelled;
                // Note: Cancellation reason can be stored in a separate logging system
                break;

            default:
                return false;
        }

        appointment.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<List<StaffCustomerResponse>> GetStaffCustomersAsync(int staffId)
    {
        var customers = await _context.Appointments
            .Where(a => a.StaffId == staffId && a.Status == AppointmentStatus.Completed)
            .Include(a => a.Customer)
            .Include(a => a.Service)
            .GroupBy(a => a.CustomerId)
            .Select(g => new StaffCustomerResponse
            {
                CustomerId = g.Key,
                CustomerName = g.First().Customer.FullName,
                Phone = g.First().Customer.Phone,
                Email = g.First().Customer.Email,
                TotalVisits = g.Count(),
                TotalSpent = g.Sum(a => a.Service.Price),
                LastVisit = g.Max(a => a.StartTime)
            })
            .OrderByDescending(c => c.TotalVisits)
            .ToListAsync();

        return customers;
    }

    public async Task<StaffRevenueResponse> GetStaffRevenueAsync(int staffId, DateTime? startDate, DateTime? endDate)
    {
        var staff = await _context.StaffProfiles
            .Include(s => s.User)
            .FirstOrDefaultAsync(s => s.Id == staffId);

        if (staff == null)
        {
            return new StaffRevenueResponse
            {
                StaffId = staffId,
                StaffName = "Unknown",
                StartDate = startDate ?? DateTime.Today.AddMonths(-1),
                EndDate = endDate ?? DateTime.Today,
                TotalAppointments = 0,
                CompletedAppointments = 0,
                TotalRevenue = 0,
                AverageRevenuePerAppointment = 0
            };
        }

        var start = startDate ?? DateTime.Today.AddMonths(-1);
        var end = endDate ?? DateTime.Today;

        var appointments = await _context.Appointments
            .Where(a => a.StaffId == staffId &&
                       a.StartTime >= start &&
                       a.StartTime <= end)
            .Include(a => a.Service)
            .ToListAsync();

        var completedAppointments = appointments.Where(a => a.Status == AppointmentStatus.Completed).ToList();
        var totalRevenue = completedAppointments.Sum(a => a.Service.Price);

        return new StaffRevenueResponse
        {
            StaffId = staffId,
            StaffName = staff.User.FullName,
            StartDate = start,
            EndDate = end,
            TotalAppointments = appointments.Count,
            CompletedAppointments = completedAppointments.Count,
            TotalRevenue = totalRevenue,
            AverageRevenuePerAppointment = completedAppointments.Count > 0 ? totalRevenue / completedAppointments.Count : 0
        };
    }

    public async Task<bool> UpdateStaffProfileAsync(int staffId, UpdateStaffProfileRequest request)
    {
        var staff = await _context.StaffProfiles
            .Include(s => s.User)
            .FirstOrDefaultAsync(s => s.Id == staffId);

        if (staff == null)
            return false;

        // Update staff profile
        if (request.Bio != null)
            staff.Bio = request.Bio;
        
        if (request.Position != null)
            staff.Position = request.Position;
        
        if (request.SkillSet != null)
            staff.SkillSet = request.SkillSet;
        
        if (request.ExperienceYears.HasValue)
            staff.ExperienceYears = request.ExperienceYears.Value;
        
        // Update avatar in User table
        if (request.AvatarUrl != null)
            staff.User.AvatarUrl = request.AvatarUrl;

        staff.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<List<StaffWorkHistoryResponse>> GetWorkHistoryAsync(int staffId, DateTime? startDate, DateTime? endDate)
    {
        var start = startDate ?? DateTime.Today.AddMonths(-1);
        var end = endDate ?? DateTime.Today.AddDays(1);

        var history = await _context.Appointments
            .Where(a => a.StaffId == staffId &&
                       a.StartTime >= start &&
                       a.StartTime < end)
            .Include(a => a.Customer)
            .Include(a => a.Service)
            .OrderByDescending(a => a.StartTime)
            .Select(a => new StaffWorkHistoryResponse
            {
                AppointmentId = a.Id,
                StartTime = a.StartTime,
                EndTime = a.EndTime,
                CustomerName = a.Customer.FullName,
                ServiceName = a.Service.Name,
                ServicePrice = a.Service.Price,
                Status = a.Status.ToString(),
                CreatedAt = a.CreatedAt
            })
            .ToListAsync();

        return history;
    }
}
