using System.ComponentModel.DataAnnotations;

namespace AIECommerce.Shared.Entities;

public class Order : BaseEntity
{
    [Required]
    public Guid UserId { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string OrderNumber { get; set; } = string.Empty;
    
    [Required]
    public OrderStatus Status { get; set; }
    
    [Required]
    public decimal TotalAmount { get; set; }
    
    public decimal? DiscountAmount { get; set; }
    
    public decimal? TaxAmount { get; set; }
    
    public decimal? ShippingAmount { get; set; }
    
    [Required]
    public PaymentMethod PaymentMethod { get; set; }
    
    [Required]
    public PaymentStatus PaymentStatus { get; set; }
    
    public DateTime? PaymentDate { get; set; }
    
    public DateTime? ShippedDate { get; set; }
    
    public DateTime? DeliveredDate { get; set; }
    
    [Required]
    [MaxLength(200)]
    public string ShippingAddress { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string ShippingCity { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string ShippingCountry { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(10)]
    public string ShippingPostalCode { get; set; } = string.Empty;
    
    [MaxLength(20)]
    public string? TrackingNumber { get; set; }
    
    // ML Fraud Detection Features
    public double? FraudRiskScore { get; set; }
    
    public string? FraudRiskLevel { get; set; } // Low, Medium, High
    
    public List<string>? FraudRiskFactors { get; set; }
    
    public bool IsFraudulent { get; set; }
    
    public string? FraudDetectionNotes { get; set; }
    
    // Behavioral Features
    public TimeSpan? TimeFromLastOrder { get; set; }
    
    public int? ItemsInCart { get; set; }
    
    public decimal? AverageItemPrice { get; set; }
    
    public bool IsFirstTimeCustomer { get; set; }
    
    public string? DeviceType { get; set; }
    
    public string? IPAddress { get; set; }
    
    public string? UserAgent { get; set; }
    
    // Relationships
    public User User { get; set; } = null!;
    
    public List<OrderItem> OrderItems { get; set; } = new();
    
    public List<OrderFraudRisk> FraudRiskAssessments { get; set; } = new();
}

public enum OrderStatus
{
    Pending = 0,
    Confirmed = 1,
    Processing = 2,
    Shipped = 3,
    Delivered = 4,
    Cancelled = 5,
    Refunded = 6
}

public enum PaymentMethod
{
    CreditCard = 0,
    DebitCard = 1,
    PayPal = 2,
    BankTransfer = 3,
    Cryptocurrency = 4,
    CashOnDelivery = 5
}

public enum PaymentStatus
{
    Pending = 0,
    Processing = 1,
    Completed = 2,
    Failed = 3,
    Refunded = 4,
    Cancelled = 5
}
