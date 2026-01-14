using Microsoft.EntityFrameworkCore;
using appcattoc.Data;
using appcattoc.DTOs.Analytics;
using appcattoc.Models.Enums;

namespace appcattoc.Services;

public interface IAnalyticsService
{
    Task<RevenueAnalyticsResponse> GetRevenueAnalyticsAsync(RevenueAnalyticsRequest request);
    Task<List<StaffPerformanceResponse>> GetStaffPerformanceAsync(int shopId, DateTime? startDate, DateTime? endDate);
}

public class AnalyticsService : IAnalyticsService
{
    private readonly BarberDbContext _context;

    public AnalyticsService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<RevenueAnalyticsResponse> GetRevenueAnalyticsAsync(RevenueAnalyticsRequest request)
    {
        var startDate = new DateTime(request.Year, request.Month, 1);
        var endDate = startDate.AddMonths(1);

        var query = _context.Invoices
            .Include(i => i.Appointment)
            .ThenInclude(a => a.Staff)
            .Where(i => i.CreatedAt >= startDate && i.CreatedAt < endDate);

        if (request.ShopId.HasValue)
        {
            query = query.Where(i => i.Appointment.Staff.ShopId == request.ShopId.Value);
        }

        var invoices = await query.ToListAsync();

        var dailyBreakdown = invoices
            .GroupBy(i => i.CreatedAt.Date)
            .Select(g => new DailyRevenueResponse
            {
                Date = g.Key,
                TotalRevenue = g.Sum(i => i.TotalAmount),
                AppointmentCount = g.Count()
            })
            .OrderBy(d => d.Date)
            .ToList();

        return new RevenueAnalyticsResponse
        {
            Month = request.Month,
            Year = request.Year,
            TotalRevenue = invoices.Sum(i => i.TotalAmount),
            DailyBreakdown = dailyBreakdown
        };
    }

    public async Task<List<StaffPerformanceResponse>> GetStaffPerformanceAsync(
        int shopId, DateTime? startDate, DateTime? endDate)
    {
        var query = _context.Appointments
            .Include(a => a.Staff)
                .ThenInclude(s => s.User)
            .Include(a => a.Invoice)
            .Where(a => a.Staff.ShopId == shopId && a.Status == AppointmentStatus.Completed);

        if (startDate.HasValue)
        {
            query = query.Where(a => a.CreatedAt >= startDate.Value);
        }

        if (endDate.HasValue)
        {
            query = query.Where(a => a.CreatedAt <= endDate.Value);
        }

        var appointments = await query.ToListAsync();

        return appointments
            .GroupBy(a => new { a.StaffId, StaffName = a.Staff.User.FullName })
            .Select(g => new StaffPerformanceResponse
            {
                StaffId = g.Key.StaffId,
                StaffName = g.Key.StaffName,
                CompletedAppointments = g.Count(),
                TotalRevenue = g.Where(a => a.Invoice != null).Sum(a => a.Invoice!.TotalAmount),
                AverageRating = 0.0
            })
            .OrderByDescending(s => s.CompletedAppointments)
            .ToList();
    }
}
