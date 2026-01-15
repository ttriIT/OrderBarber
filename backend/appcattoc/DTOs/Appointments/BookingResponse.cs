namespace appcattoc.DTOs.Appointments
{
    public class BookingResponse
    {
        public int BookingId { get; set; }
        public string BarberName { get; set; } = string.Empty;
        public string ShopName { get; set; } = string.Empty;

        public DateTime BookingDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }

        public int Status { get; set; }

        public int? CustomerId { get; set; }
        public string? CustomerName { get; set; }

        public int? ServiceId { get; set; }
        public string? ServiceName { get; set; }
        public decimal? ServicePrice { get; set; }
    }
}
