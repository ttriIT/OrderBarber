namespace appcattoc.DTOs.Analytics;

public class RevenueAnalyticsRequest
{
    public int Month { get; set; }
    public int Year { get; set; }
    public int? ShopId { get; set; }
}

public class DailyRevenueResponse
{
    public DateTime Date { get; set; }
    public decimal TotalRevenue { get; set; }
    public int AppointmentCount { get; set; }
}

public class RevenueAnalyticsResponse
{
    public int Month { get; set; }
    public int Year { get; set; }
    public decimal TotalRevenue { get; set; }
    public List<DailyRevenueResponse> DailyBreakdown { get; set; } = new();
}

public class StaffPerformanceResponse
{
    public int StaffId { get; set; }
    public string StaffName { get; set; } = string.Empty;
    public int CompletedAppointments { get; set; }
    public decimal TotalRevenue { get; set; }
    public double AverageRating { get; set; }
}
