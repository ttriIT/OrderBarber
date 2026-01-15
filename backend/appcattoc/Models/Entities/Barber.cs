using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace appcattoc.Models.Entities;

public class Barber
{
    public int BarberId { get; set; }
    public required string Name { get; set; }
    public required string Phone { get; set; }
    public string? AvatarUrl { get; set; }
    public double Rating { get; set; }
    public bool IsActive { get; set; }

    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}

