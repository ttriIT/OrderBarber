using System.ComponentModel.DataAnnotations;

namespace appcattoc.DTOs.Invoices;

public class CreateInvoiceRequest
{
    [Required]
    public int AppointmentId { get; set; }

    [Required]
    public decimal TotalAmount { get; set; }

    [Required]
    public string PaymentMethod { get; set; } = "Cash";
}

public class InvoiceResponse
{
    public int Id { get; set; }
    public int AppointmentId { get; set; }
    public decimal TotalAmount { get; set; }
    public string PaymentMethod { get; set; } = string.Empty;
    public int CreatedByStaffId { get; set; }
    public string CreatedByStaffName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
