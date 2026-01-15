using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using appcattoc.Models.Enums;

namespace appcattoc.Models.Entities;

public class Booking
{
    public int BookingId { get; set; }

    public int BarberId { get; set; }
    public required Barber Barber { get; set; }

    public int ShopId { get; set; }
    public required Shop Shop { get; set; }

    public int? CustomerId { get; set; } // Nullable if guest
    public string? CustomerName { get; set; }
    public string? CustomerPhone { get; set; }

    public int? ServiceId { get; set; }
    public Service? Service { get; set; }

    public DateTime BookingDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }

    public BookingStatus Status { get; set; } = BookingStatus.Pending;
}

