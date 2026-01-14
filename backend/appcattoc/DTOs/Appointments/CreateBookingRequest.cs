namespace appcattoc.DTOs.Appointments
{
    public class CreateBookingRequest
    {
        public int BarberId { get; set; }
        public int ShopId { get; set; }

        public required string CustomerName { get; set; }
        public required string CustomerPhone { get; set; }

        public DateTime BookingDate { get; set; }

        public required string StartTime { get; set; }
        public required string EndTime { get; set; }
        
        // Added to match Frontend
        public List<int> ServiceIds { get; set; } = new List<int>();
        public required string Note { get; set; }
    }
}
