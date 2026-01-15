using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using appcattoc.Models.Enums;

namespace appcattoc.Models.Entities;

[Table("Appointments")]
[Index(nameof(StaffId), nameof(StartTime), nameof(EndTime))]
public class Appointment
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required]
    [ForeignKey(nameof(Customer))]
    public int CustomerId { get; set; }

    [Required]
    [ForeignKey(nameof(Staff))]
    public int StaffId { get; set; }

    [Required]
    [ForeignKey(nameof(Service))]
    public int ServiceId { get; set; }

    [Required]
    public DateTime StartTime { get; set; }

    [Required]
    public DateTime EndTime { get; set; }

    [Required]
    public AppointmentStatus Status { get; set; } = AppointmentStatus.Pending;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    // Navigation Properties
    public User Customer { get; set; } = null!;
    public StaffProfile Staff { get; set; } = null!;
    public Service Service { get; set; } = null!;
    public Invoice? Invoice { get; set; }
}
