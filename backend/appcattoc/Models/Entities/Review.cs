using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace appcattoc.Models.Entities;

[Table("Reviews")]
public class Review
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required]
    [ForeignKey(nameof(User))]
    public int UserId { get; set; }

    public int? ShopId { get; set; }

    public int? StaffId { get; set; }
    
    [Required]
    [ForeignKey(nameof(Appointment))]
    public int AppointmentId { get; set; }
    
    public int? ServiceId { get; set; }

    [Required]
    [Range(1, 5)]
    public int Rating { get; set; }

    [MaxLength(500)]
    public string? Comment { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    public User User { get; set; } = null!;
    public Shop? Shop { get; set; }
    public StaffProfile? Staff { get; set; }    public Appointment Appointment { get; set; } = null!;    public Service? Service { get; set; }
}
