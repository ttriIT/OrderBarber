using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace appcattoc.Models.Entities;

[Table("Vouchers")]
public class Voucher
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required]
    [MaxLength(100)]
    public string Code { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    [Required]
    [Column(TypeName = "decimal(18,2)")]
    public decimal DiscountAmount { get; set; }

    // Discount type: 0 = Fixed Amount, 1 = Percentage
    [Required]
    public int DiscountType { get; set; } = 0;

    // Maximum discount amount (if percentage)
    [Column(TypeName = "decimal(18,2)")]
    public decimal? MaxDiscountAmount { get; set; }

    // Minimum order amount to use voucher
    [Column(TypeName = "decimal(18,2)")]
    public decimal MinimumAmount { get; set; } = 0;

    [Required]
    public DateTime StartDate { get; set; }

    [Required]
    public DateTime EndDate { get; set; }

    [Required]
    public int MaxUsage { get; set; }

    public int CurrentUsage { get; set; } = 0;

    // Maximum usage per user
    public int MaxUsagePerUser { get; set; } = 1;

    [Required]
    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    [MaxLength(500)]
    public string? Notes { get; set; }

    // Shop-specific voucher (NULL = for all shops)
    [ForeignKey(nameof(Shop))]
    public int? ShopId { get; set; }

    // Navigation Properties
    public Shop? Shop { get; set; }
}
