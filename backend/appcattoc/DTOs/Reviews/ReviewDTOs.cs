using System.ComponentModel.DataAnnotations;

namespace appcattoc.DTOs.Reviews;

public class CreateReviewRequest
{
    [Required]
    public int ShopId { get; set; }

    public int? StaffId { get; set; }
    
    [Required]
    public int AppointmentId { get; set; }
    
    public int? ServiceId { get; set; }

    [Required]
    [Range(1, 5)]
    public int Rating { get; set; }

    [MaxLength(500)]
    public string? Comment { get; set; }
}

public class ReviewResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public int? ShopId { get; set; }
    public int? StaffId { get; set; }
    public int? ServiceId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; }
}
