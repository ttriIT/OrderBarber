using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using appcattoc.Models.Enums;

namespace appcattoc.Models.Entities;

[Table("ChatSessions")]
public class ChatSession
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [ForeignKey(nameof(User1))]
    public int? User1_Id { get; set; }

    [ForeignKey(nameof(User2))]
    public int? User2_Id { get; set; }

    [Required]
    public ChatSessionType Type { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    // Navigation Properties
    public User? User1 { get; set; }
    public User? User2 { get; set; }
    public ICollection<ChatMessage> Messages { get; set; } = new List<ChatMessage>();
}
