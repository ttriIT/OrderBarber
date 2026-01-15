using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace appcattoc.Models.Entities;

[Table("StaffProfiles")]
public class StaffProfile
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required]
    [ForeignKey(nameof(User))]
    public int UserId { get; set; }

    [Required]
    [ForeignKey(nameof(Shop))]
    public int ShopId { get; set; }

    [Required]
    public bool IsActive { get; set; } = true;

    [MaxLength(1000)]
    public string? SkillSet { get; set; }

    [MaxLength(1000)]
    public string? Bio { get; set; }

    [MaxLength(100)]
    public string? Position { get; set; }

    public int ExperienceYears { get; set; } = 0;

    public double Rating { get; set; } = 0.0;

    public int ReviewCount { get; set; } = 0;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    // Navigation Properties
    public User User { get; set; } = null!;
    public Shop Shop { get; set; } = null!;
    public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
}
