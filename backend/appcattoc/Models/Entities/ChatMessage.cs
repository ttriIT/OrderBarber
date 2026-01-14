using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace appcattoc.Models.Entities;

[Table("ChatMessages")]
public class ChatMessage
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required]
    [ForeignKey(nameof(Session))]
    public int SessionId { get; set; }

    [ForeignKey(nameof(Sender))]
    public int? SenderId { get; set; }

    [Required]
    public string Content { get; set; } = string.Empty;

    public bool IsImage { get; set; } = false;
    
    public bool IsAI { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    public ChatSession Session { get; set; } = null!;
    public User? Sender { get; set; }
}
