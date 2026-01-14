using System.ComponentModel.DataAnnotations;

namespace appcattoc.DTOs.Appointments;

public class CreateAppointmentRequest
{
    [Required]
    public int StaffId { get; set; }

    [Required]
    public int ServiceId { get; set; }

    [Required]
    public DateTime RequestedTime { get; set; }
}

public class CreateWalkInRequest
{
    [Required]
    public int CustomerId { get; set; }

    [Required]
    public int StaffId { get; set; }

    [Required]
    public int ServiceId { get; set; }

    [Required]
    public DateTime StartTime { get; set; }
}

public class AppointmentResponse
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public int StaffId { get; set; }
    public string StaffName { get; set; } = string.Empty;
    public int ServiceId { get; set; }
    public string ServiceName { get; set; } = string.Empty;
    public decimal ServicePrice { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
