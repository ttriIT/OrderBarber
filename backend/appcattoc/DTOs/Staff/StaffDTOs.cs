namespace appcattoc.DTOs.Staff;

public class StaffScheduleResponse
{
    public DateTime Date { get; set; }
    public List<ScheduleSlot> Slots { get; set; } = new();
}

public class ScheduleSlot
{
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public bool IsBooked { get; set; }
    public int? AppointmentId { get; set; }
    public string? CustomerName { get; set; }
    public string? ServiceName { get; set; }
}

public class UpdateAppointmentStatusRequest
{
    public required string Status { get; set; } // "Confirmed", "Completed", "Cancelled"
    public string? CancellationReason { get; set; }
}

public class StaffCustomerResponse
{
    public int CustomerId { get; set; }
    public required string CustomerName { get; set; }
    public required string Phone { get; set; }
    public string? Email { get; set; }
    public int TotalVisits { get; set; }
    public decimal TotalSpent { get; set; }
    public DateTime? LastVisit { get; set; }
}

public class StaffRevenueResponse
{
    public int StaffId { get; set; }
    public required string StaffName { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int TotalAppointments { get; set; }
    public int CompletedAppointments { get; set; }
    public decimal TotalRevenue { get; set; }
    public decimal AverageRevenuePerAppointment { get; set; }
}

public class UpdateStaffProfileRequest
{
    public string? Bio { get; set; }
    public string? Position { get; set; }
    public string? SkillSet { get; set; }
    public int? ExperienceYears { get; set; }
    public string? AvatarUrl { get; set; }
}

public class StaffWorkHistoryResponse
{
    public int AppointmentId { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public required string CustomerName { get; set; }
    public required string ServiceName { get; set; }
    public decimal ServicePrice { get; set; }
    public required string Status { get; set; }
    public DateTime CreatedAt { get; set; }
}
