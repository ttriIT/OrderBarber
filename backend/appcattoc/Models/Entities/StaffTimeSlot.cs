using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace appcattoc.Models.Entities;

public class StaffTimeSlot
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int StaffId { get; set; }

    [Required]
    public DateTime Date { get; set; } // ngày làm việc

    [Required]
    public TimeSpan StartTime { get; set; } // ví dụ 08:00

    [Required]
    public TimeSpan EndTime { get; set; }   // ví dụ 08:30

    // bật / tắt slot
    public bool IsAvailable { get; set; } = true;

    // nghỉ cả ngày
    public bool IsDayOff { get; set; } = false;

    // navigation (không bắt buộc nhưng nên có)
    public StaffProfile Staff { get; set; } = null!;
}
