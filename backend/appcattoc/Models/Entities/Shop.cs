using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace appcattoc.Models.Entities;

[Table("Shops")]
public class Shop
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required]
    [ForeignKey(nameof(Manager))]
    public int ManagerId { get; set; }

    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string Location { get; set; } = string.Empty;

    [MaxLength(20)]
    public string? Phone { get; set; }

    [MaxLength(1000)]
    public string? Description { get; set; }

    [MaxLength(500)]
    public string? ImageUrl { get; set; }

    public double Rating { get; set; } = 0.0;

    public int ReviewCount { get; set; } = 0;

    [Required]
    public TimeSpan OpenTime { get; set; }

    [Required]
    public TimeSpan CloseTime { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    // Navigation Properties
    public User Manager { get; set; } = null!;
    public ICollection<StaffProfile> StaffProfiles { get; set; } = new List<StaffProfile>();
    public ICollection<Service> Services { get; set; } = new List<Service>();
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
