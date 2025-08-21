using System.ComponentModel.DataAnnotations;

namespace AIECommerce.Shared.Entities;

public class User : BaseEntity
{
    [Required]
    [EmailAddress]
    [MaxLength(100)]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string Username { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string LastName { get; set; } = string.Empty;
    
    [MaxLength(20)]
    public string? PhoneNumber { get; set; }
    
    public DateTime? DateOfBirth { get; set; }
    
    [MaxLength(100)]
    public string? Country { get; set; }
    
    [MaxLength(100)]
    public string? City { get; set; }
    
    [MaxLength(200)]
    public string? Address { get; set; }
    
    [MaxLength(10)]
    public string? PostalCode { get; set; }
    
    // ML Features for Personalization
    public List<string> PreferredCategories { get; set; } = new();
    
    public List<string> PreferredBrands { get; set; } = new();
    
    public decimal? AverageOrderValue { get; set; }
    
    public int TotalOrders { get; set; }
    
    public DateTime? LastOrderDate { get; set; }
    
    public DateTime? LastLoginDate { get; set; }
    
    public int LoginCount { get; set; }
    
    public double? ChurnProbability { get; set; }
    
    public double? LifetimeValue { get; set; }
    
    public string? CustomerSegment { get; set; }
    
    // Behavioral Features
    public List<string> BrowsingHistory { get; set; } = new();
    
    public List<string> SearchHistory { get; set; } = new();
    
    public List<string> WishlistItems { get; set; } = new();
    
    public List<string> CartAbandonments { get; set; } = new();
    
    // Vector embeddings for ML
    public List<double>? PreferenceEmbedding { get; set; }
    
    public List<double>? BehaviorEmbedding { get; set; }
    
    // Relationships
    public List<Order> Orders { get; set; } = new();
    
    public List<Review> Reviews { get; set; } = new();
    
    public List<UserRecommendation> Recommendations { get; set; } = new();
    
    public List<UserFraudRisk> FraudRiskAssessments { get; set; } = new();
}
